// lib/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../services/firestore_service.dart'; // Import your Firestore service
import '../services/auth_service.dart'; // Import AuthService
import 'dart:developer'; // Import for debugPrint

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true; // To toggle between login and signup

  void _trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus(); // Close the keyboard

    if (isValid) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final firestoreService = Provider.of<FirestoreService>(context, listen: false);
        UserCredential? userCredential; // Made nullable

        if (_isLogin) {
          // Log user in using AuthService
          userCredential = await authService.signInWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
        } else {
          // Sign user up using AuthService
          userCredential = await authService.signUpWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
          // Assign 'user' role and save email to newly created user document using FirestoreService
           if (userCredential != null && userCredential.user != null) { // Added null check
             await firestoreService.createUser(
              userCredential.user!.uid,
              'user', // Default role for new signups
              email: _emailController.text.trim(), // Pass email
            );
           }
        }

        // Navigation is now handled by the GoRouter redirect in main.dart

      } on FirebaseAuthException catch (e) {
        String message = 'An error occurred, please check your credentials.';
        if (e.message != null) {
          message = e.message!;
        }
         if (mounted) { // Added mounted check
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
         }
      } catch (e) {
        debugPrint('Error during authentication: $e'); // Replaced print with debugPrint
         if (mounted) { // Added mounted check
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('An unexpected error occurred.'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
         }
      } finally {
         if (mounted) { // Added mounted check
            setState(() {
              _isLoading = false;
            });
         }
      }
    }
  }

  // Rest of the AuthScreenState class
  @override
  Widget build(BuildContext context) {
    // ... your existing build method ...
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Signup'),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      key: const ValueKey('email'),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email address'),
                      validator: (value) {
                        if (value!.isEmpty || !value.contains('@')) {
                          return 'Please enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      key: const ValueKey('password'),
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 6) {
                          return 'Password must be at least 6 characters long.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    if (_isLoading)
                      const CircularProgressIndicator(),
                    if (!_isLoading)
                      ElevatedButton(
                        onPressed: _trySubmit,
                        child: Text(_isLogin ? 'Login' : 'Signup'),
                      ),
                    if (!_isLoading)
                      TextButton(
                        child: Text(_isLogin
                            ? 'Create new account'
                            : 'I already have an account'),
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
