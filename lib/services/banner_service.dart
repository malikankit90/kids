      import 'package:cloud_firestore/cloud_firestore.dart';
      import 'package:myapp/models/app_banner.dart'; // Renamed import
      
      class BannerService {
        final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      
        Stream<List<AppBanner>> getBanners() { // Refactored to AppBanner
          return _firestore.collection('banners').snapshots().map((snapshot) {
            return snapshot.docs.map((doc) => AppBanner.fromFirestore(doc)).toList(); // Refactored to AppBanner
          });
        }
      
        Future<void> addBanner(AppBanner banner) async { // Refactored to AppBanner
          try {
             await _firestore.collection('banners').add(banner.toMap());
          } catch (e) {
            print('Error adding banner: $e');
            rethrow;
          }
        }
      
        Future<void> updateBanner(AppBanner banner) async { // Refactored to AppBanner
          try {
             await _firestore.collection('banners').doc(banner.id).update(banner.toMap());
          } catch (e) {
            print('Error updating banner: $e');
            rethrow;
          }
        }
      
        Future<void> deleteBanner(String id) async {
          try {
            await _firestore.collection('banners').doc(id).delete();
          } catch (e) {
            print('Error deleting banner: $e');
            rethrow;
          }
        }
      }