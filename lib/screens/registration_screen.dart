import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/utils/user_roles.dart';
import 'package:myapp/services/firestore_service.dart'; // Import FirestoreService
import 'dart:developer'; // Import for debugPrint

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  UserRole selectedRole = UserRole.Customer; // Default role
  String error = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: _isLoading
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
                    DropdownButtonFormField<UserRole>(
                      value: selectedRole,
                      decoration: const InputDecoration(hintText: 'Select Role'),
                      items: UserRole.values.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role.toString().split('.').last), // Display role name nicely
                        );
                      }).toList(),
                      onChanged: (role) {
                        setState(() {
                          selectedRole = role!;
                        });
                      },
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      child: const Text('Register'),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                            error = ''; // Clear previous errors
                          });
                          try {
                             UserCredential? result = await authService.signUpWithEmailAndPassword(
                              email, password); // Made nullable
                             if (result != null && result.user != null) {
                                // Create user document in Firestore with selected role and email
                                await firestoreService.createUser(
                                  result.user!.uid,
                                  selectedRole.toString().split('.').last.toLowerCase(), // Save role as lowercase string
                                  email: email,
                                );
                                // Navigate back after successful registration
                                if (mounted) Navigator.pop(context);
                             } else {
                                // Handle cases where registration fails but no exception is thrown
                                setState(() => error = 'Registration failed.');
                             }
                          } catch (e) {
                            setState(() => error = 'Error registering user: ${e.toString()}');
                            debugPrint('Error during registration: $e'); // Replaced print with debugPrint
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
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
