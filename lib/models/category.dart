import 'cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;
  final List<String> subcategories; // Add subcategories field

  Category({
    required this.id,
    required this.name,
    this.subcategories = const [], // Initialize as empty list
  });

  // Factory method to create a Category from a Firestore DocumentSnapshot
  factory Category.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Category(
      id: doc.id,
      name: data['name'] ?? '',
      subcategories: List<String>.from(data['subcategories'] ?? []), // Read subcategories
    );
  }

  // Method to convert a Category to a Firestore Document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'subcategories': subcategories, // Write subcategories
    };
  }
}
