      import 'package:firebase_auth/firebase_auth.dart';
      import 'package:flutter/material.dart';
       // Removed unused import
      
      class AuthService with ChangeNotifier {
        final FirebaseAuth _auth = FirebaseAuth.instance;
      
        // Stream to listen to authentication state changes
        Stream<User?> get user => _auth.authStateChanges();
      
        // Method for sign in
        Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
          try {
            UserCredential userCredential = await _auth.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
            return userCredential;
          } on FirebaseAuthException catch (e) {
            debugPrint('Error signing in: ${e.message}'); // Replaced print with debugPrint
            rethrow; // Re-throw the exception to be caught by the caller
          }
           catch (e) {
            debugPrint('Error signing in: $e'); // Replaced print with debugPrint
             rethrow; // Re-throw the exception to be caught by the caller
          }
        }

         // Method for sign up
        Future<UserCredential?> signUpWithEmailAndPassword(String email, String password) async {
          try {
            UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
              email: email,
              password: password,
            );
            return userCredential;
          } on FirebaseAuthException catch (e) {
            debugPrint('Error signing up: ${e.message}'); // Replaced print with debugPrint
            rethrow; // Re-throw the exception to be caught by the caller
          }
           catch (e) {
            debugPrint('Error signing up: $e'); // Replaced print with debugPrint
             rethrow; // Re-throw the exception to be caught by the caller
          }
        }
      
        // Example sign out method
        Future<void> signOut() async {
          try {
            await _auth.signOut();
          } catch (e) {
            debugPrint('Error signing out: $e'); // Replaced print with debugPrint
          }
        }
      }