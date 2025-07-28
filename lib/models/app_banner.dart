      import 'package:cloud_firestore/cloud_firestore.dart';
      
      class AppBanner {
        final String id;
        final String imageUrl;
        final String targetScreen;
      
        AppBanner({
          required this.id,
          required this.imageUrl,
          required this.targetScreen,
        });
      
        factory AppBanner.fromFirestore(DocumentSnapshot doc) {
          final data = doc.data() as Map<String, dynamic>;
          return AppBanner(
            id: doc.id,
            imageUrl: data['imageUrl'] ?? '',
            targetScreen: data['targetScreen'] ?? '',
          );
        }
      
         Map<String, dynamic> toMap() {
          return {
            'imageUrl': imageUrl,
            'targetScreen': targetScreen,
          };
        }
      }