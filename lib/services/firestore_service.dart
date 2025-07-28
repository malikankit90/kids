import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new user document in Firestore with additional details
  Future<void> createUser(String uid, String role, {String? email, String? name}) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'role': role,
        'createdAt': Timestamp.now(), // Optional: add a timestamp
        if (email != null) 'email': email, // Add email if provided
        if (name != null) 'name': name,   // Add name if provided
      });
    } catch (e) {
      print('Error creating user document: $e');
      // Handle the error appropriately (e.g., throw an exception)
      rethrow; // Re-throw the error to be caught in the calling function
    }
  }

  // Get a user document from Firestore
  Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      } else {
        return null; // User document not found
      }
    } catch (e) {
      print('Error getting user document: $e');
      // Handle the error appropriately
      return null;
    }
  }

  // You can add more methods here for other Firestore operations
}