      import 'package:firebase_auth/firebase_auth.dart';
      import 'package:flutter/material.dart';
      
      class AuthService with ChangeNotifier {
        final FirebaseAuth _auth = FirebaseAuth.instance;
      
        // Stream to listen to authentication state changes
        Stream<User?> get user => _auth.authStateChanges();
      
        // Add methods for sign in, sign out, etc. here
      
        // Example sign out method
        Future<void> signOut() async {
          try {
            await _auth.signOut();
          } catch (e) {
            print('Error signing out: $e');
          }
        }
      }