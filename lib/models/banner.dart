import 'cloud_firestore/cloud_firestore.dart';

class Banner {
  final String id;
  final String imageUrl;
  final String? targetScreen;
  final int? order;

  Banner({
    required this.id,
    required this.imageUrl,
    this.targetScreen,
    this.order,
  });

  // Factory method to create a Banner from a Firestore DocumentSnapshot
  factory Banner.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Banner(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      targetScreen: data['targetScreen'],
      order: (data['order'] ?? 0).toInt(),
    );
  }

  // Method to convert a Banner to a Firestore Document
  Map<String, dynamic> toFirestore() {
    return {
      'imageUrl': imageUrl,
      'targetScreen': targetScreen,
      'order': order,
    };
  }
}
