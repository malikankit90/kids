import 'cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String subCategory;
  final List<String> images;
  final int stock;
  final String ageGroup;
  final String gender;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.subCategory,
    required this.images,
    required this.stock,
    required this.ageGroup,
    required this.gender,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method to create a Product from a Firestore DocumentSnapshot
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      category: data['category'] ?? '',
      subCategory: data['subCategory'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      stock: (data['stock'] ?? 0).toInt(),
      ageGroup: data['ageGroup'] ?? '',
      gender: data['gender'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  // Method to convert a Product to a Firestore Document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'subCategory': subCategory,
      'images': images,
      'stock': stock,
      'ageGroup': ageGroup,
      'gender': gender,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
