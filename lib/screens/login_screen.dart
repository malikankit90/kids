import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:myapp/screens/registration_screen.dart';
import 'package:myapp/services/auth_service.dart';
import 'dart:developer'; // Import for debugPrint

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String error = '';
  bool _isLoading = false; // Added loading state

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false); // Access AuthService via Provider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: _isLoading // Show loading indicator when loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(hintText: 'Email'),
                      validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                      onChanged: (val) {
                        setState(() => email = val);
                      },
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      decoration: const InputDecoration(hintText: 'Password'),
                      validator: (val) =>
                          val!.length < 6 ? 'Enter a password 6+ chars long' : null,
                      obscureText: true,
                      onChanged: (val) {
                        setState(() => password = val);
                      },
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      child: const Text('Login'),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                            error = ''; // Clear previous errors
                          });
                          try {
                            // Use the injected AuthService
                            await authService.signInWithEmailAndPassword(email, password); // Removed unused result variable
                            // Authentication state change is handled by GoRouter redirect in main.dart
                          } catch (e) {
                             setState(() => error = 'Could not sign in with those credentials.');
                             debugPrint('Login Error: $e'); // Replaced print with debugPrint
                          } finally {
                             if (mounted) { // Added mounted check
                               setState(() {
                                 _isLoading = false;
                               });
                             }
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      error,
                      style: const TextStyle(color: Colors.red, fontSize: 14.0),
                    ),
                    const SizedBox(height: 20.0),
                     GestureDetector(
                      onTap: () {
                         // Use Navigator.push for navigating to RegistrationScreen
                         if (mounted) { // Added mounted check
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistrationScreen()));
                         }
                      },
                      child: const Text("Don't have an account? Register here."),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
