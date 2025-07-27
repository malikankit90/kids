import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload an image to Firebase Storage
  Future<String> uploadImage(File imageFile, String path) async {
    Reference ref = _storage.ref().child(path);
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // Delete an image from Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    Reference ref = _storage.refFromURL(imageUrl);
    await ref.delete();
  }

  // You might add more methods here for listing files, etc.
}
