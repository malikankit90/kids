import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer';

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
    log('LoadingScreen: Fetching user role...');
    final user = FirebaseAuth.instance.currentUser;
    final userRoleProvider = Provider.of<UserRoleProvider>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    if (user != null) {
      log('LoadingScreen: User is logged in with UID: ${user.uid}');
      try {
        // Fetch the user document from Firestore to get the role
        log('LoadingScreen: Calling firestoreService.getUser(${user.uid})');
        final userData = await firestoreService.getUser(user.uid);

        log('LoadingScreen: Firestore user data fetched: $userData');

        String role = 'user'; // Default role
        if (userData != null && userData.containsKey('role')) {
          role = userData['role'];
           log('LoadingScreen: 'role' key found in userData.'); // Corrected log syntax with escaped quotes
        } else if (userData != null) {
           log('LoadingScreen: 'role' key NOT found in userData.'); // Corrected log syntax with escaped quotes
        } else {
           log('LoadingScreen: userData is null.');
        }

        log('LoadingScreen: Extracted role: $role');

        userRoleProvider.setUserRole(role);
        log('LoadingScreen: User role set in provider: $role');

        // Redirect based on role
        if (role == 'admin') {
          log('LoadingScreen: Redirecting to /admin');
          // Ensure the admin route is correctly defined in GoRouter
          context.go('/admin');
        } else {
          log('LoadingScreen: Redirecting to /user');
          // Ensure the user route is correctly defined in GoRouter
          context.go('/'); // Redirect to the root path for regular users
        }

      } catch (e) {
        log('LoadingScreen: Error fetching user role: $e', error: e);
        // Redirect to auth or a general error screen on error
        context.go('/auth'); // Or an error screen
      }
    } else {
      // If user is null, redirect to authentication
      log('LoadingScreen: User is null. Redirecting to auth.');
      userRoleProvider.setUserRole(null); // Clear role for logged out user
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    log('Building LoadingScreen...');
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
