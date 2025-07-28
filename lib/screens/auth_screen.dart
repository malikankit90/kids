// lib/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../services/firestore_service.dart'; // Import your Firestore service

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true; // To toggle between login and signup

  // Add FirestoreService instance
  final FirestoreService _firestoreService = FirestoreService();

  void _trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus(); // Close the keyboard

    if (isValid) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      UserCredential userCredential;
      try {
        if (_isLogin) {
          // Log user in
          userCredential = await _auth.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
        } else {
          // Sign user up
          userCredential = await _auth.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
          // Assign 'user' role and save email to newly created user document
          await _firestoreService.createUser(
            userCredential.user!.uid,
            'user', // Default role for new signups
            email: _emailController.text.trim(), // Pass email
          );
        }

        // Fetch user role after authentication
        final userDoc = await _firestoreService.getUser(userCredential.user!.uid);
        final userRole = userDoc?['role'];

        // Navigate based on role, checking if widget is mounted
        if (mounted) {
          if (userRole == 'admin') {
            // Using go_router to navigate to admin dashboard
            if (Navigator.of(context).canPop()) {
               Navigator.of(context).pop(); // Pop current route if it exists
            }
             Navigator.of(context).pushReplacementNamed('/admin');
          } else {
            // Default to user home for 'user' role or if role is not found
             if (Navigator.of(context).canPop()) {
               Navigator.of(context).pop(); // Pop current route if it exists
            }
            Navigator.of(context).pushReplacementNamed('/user');
          }
        }

      } on FirebaseAuthException catch (e) {
        String message = 'An error occurred, please check your credentials.';
        if (e.message != null) {
          message = e.message!;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        print('Error during authentication or role fetching: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() {
          _isLoading = false;
        });
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
                        if (value!.isEmpty || value.length < 6) { // Changed minimum length to 6
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
