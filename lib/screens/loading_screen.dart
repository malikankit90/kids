import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer; // Import for debugPrint

import 'package:myapp/services/user_role_provider.dart';
import 'package:myapp/services/firestore_service.dart'; // Assuming you have a FirestoreService to fetch user data

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    developer.log('LoadingScreen: Fetching user role...');
    final user = FirebaseAuth.instance.currentUser;
    // Check if widget is mounted before accessing context
    if (!mounted) return;
    final userRoleProvider = Provider.of<UserRoleProvider>(
      context,
      listen: false,
    );
    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    );

    if (user != null) {
      developer.log('LoadingScreen: User is logged in with UID: ${user.uid}');
      try {
        // Fetch the user document from Firestore to get the role
        developer.log(
          'LoadingScreen: Calling firestoreService.getUser(${user.uid})',
        );
        final userData = await firestoreService.getUser(user.uid);

        developer.log('LoadingScreen: Firestore user data fetched: $userData');

        String role = 'user'; // Default role
        if (userData != null && userData.containsKey('role')) {
          role = userData['role'];
          developer.log(
            'LoadingScreen: ' + 'role' + ' key found in userData.',
          ); // Corrected log syntax with concatenation
        } else if (userData != null) {
          developer.log(
            'LoadingScreen: ' + 'role' + ' key NOT found in userData.',
          ); // Corrected log syntax with concatenation
        } else {
          developer.log('LoadingScreen: userData is null.');
        }

        developer.log('LoadingScreen: Extracted role: $role');

        userRoleProvider.setUserRole(role);
        developer.log('LoadingScreen: User role set in provider: $role');

        // Redirect based on role
        if (role == 'admin') {
          developer.log('LoadingScreen: Redirecting to /admin');
          // Ensure the admin route is correctly defined in GoRouter
          if (mounted) context.go('/admin'); // Added mounted check
        } else {
          developer.log('LoadingScreen: Redirecting to /user');
          // Ensure the user route is correctly defined in GoRouter
          if (mounted)
            context.go(
              '/',
            ); // Added mounted check and redirect to root for user
        }
      } on FirebaseAuthException catch (e) {
        developer.log(
          'LoadingScreen: FirebaseAuthException fetching user role: ${e.message}',
          error: e,
        );
        // Redirect to auth or a general error screen on error
        if (mounted) context.go('/auth'); // Added mounted check
      } catch (e) {
        developer.log('LoadingScreen: Error fetching user role: $e', error: e);
        // Check if mounted before showing SnackBar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An unexpected error occurred.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          ); // Consider showing error on screen instead of snackbar in loading
          context.go('/auth'); // Redirect to auth on error
        }
      }
    } else {
      // If user is null, redirect to authentication
      developer.log('LoadingScreen: User is null. Redirecting to auth.');
      userRoleProvider.setUserRole(null); // Clear role for logged out user
      if (mounted) context.go('/auth'); // Added mounted check
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('TEST: LoadingScreen build is called.'); // Added test debugPrint
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
