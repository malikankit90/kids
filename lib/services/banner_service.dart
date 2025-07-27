import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/banner.dart';
import 'package:myapp/services/firestore_service.dart';

class BannerService {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collectionPath = 'banners';

  // Fetch all banners, ordered by the 'order' field
  Stream<List<Banner>> getBanners() {
    return _firestoreService.getCollection(_collectionPath).map((snapshot) {
      return snapshot.docs.map((doc) => Banner.fromFirestore(doc)).toList();
    });
  }

  // Add a new banner
  Future<DocumentReference> addBanner(Banner banner) async {
    return await _firestoreService.addDocument(
        _collectionPath, banner.toFirestore());
  }

  // Update an existing banner
  Future<void> updateBanner(Banner banner) async {
    return await _firestoreService.updateDocument(
        '$_collectionPath/${banner.id}', banner.toFirestore());
  }

  // Delete a banner by ID
  Future<void> deleteBanner(String id) async {
    return await _firestoreService.deleteDocument('$_collectionPath/$id');
  }
}
