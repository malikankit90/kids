import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get a document by path
  Future<DocumentSnapshot> getDocument(String path) async {
    return await _db.doc(path).get();
  }

  // Get a collection by path
  Stream<QuerySnapshot> getCollection(String path) {
    return _db.collection(path).snapshots();
  }

  // Add a document to a collection
  Future<DocumentReference> addDocument(
      String collectionPath, Map<String, dynamic> data) async {
    return await _db.collection(collectionPath).add(data);
  }

  // Set a document with a specific ID
  Future<void> setDocument(
      String docPath, Map<String, dynamic> data) async {
    return await _db.doc(docPath).set(data);
  }

  // Update a document
  Future<void> updateDocument(
      String docPath, Map<String, dynamic> data) async {
    return await _db.doc(docPath).update(data);
  }

  // Delete a document
  Future<void> deleteDocument(String docPath) async {
    return await _db.doc(docPath).delete();
  }
}
