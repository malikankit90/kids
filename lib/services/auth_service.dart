import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/utils/user_roles.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register with email and password
  Future<User?> signUpWithEmailAndPassword(
      String email, String password, UserRole role) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      // Note: Setting custom claims should be done on the server-side
      // For simplicity in this client-side example, we will not set custom claims here.
      // You would typically use the Firebase Admin SDK or a Callable Cloud Function for this.
      // If you need to handle roles client-side, you might store the role in a Firestore document
      // associated with the user or retrieve it from the ID token after sign-in.

      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Method to get user's role from custom claims (client-side retrieval)
  Future<UserRole?> getUserRole(User user) async {
    try {
      IdTokenResult idTokenResult = await user.getIdTokenResult(true);
      final claims = idTokenResult.claims;
      if (claims != null && claims.containsKey('role')) {
        final role = claims['role'];
        if (role == 'Admin') {
          return UserRole.Admin;
        } else if (role == 'Customer') {
          return UserRole.Customer;
        }
      }
      return null; // Default to null if role claim is not present or recognized
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
