      import 'package:cloud_firestore/cloud_firestore.dart';
      
      class Product {
        final String id;
        final String name;
        final String description;
        final double price;
        final String category;
        final String subcategory;
        final List<String> imageUrls; // Changed to list of image URLs
        final int stock;
        final Timestamp createdAt;
        final Timestamp updatedAt;
        final String? ageGroup;
        final String? gender;
      
        Product({
          required this.id,
          required this.name,
          required this.description,
          required this.price,
          required this.category,
          required this.subcategory,
          required this.imageUrls, // Changed to list
          required this.stock,
          required this.createdAt,
          required this.updatedAt,
          this.ageGroup,
          this.gender,
        });

        // Add imageUrl getter for backward compatibility or if needed elsewhere
        String? get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;
      
        factory Product.fromFirestore(DocumentSnapshot doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Product(
            id: doc.id,
            name: data['name'] ?? '',
            description: data['description'] ?? '',
            price: (data['price'] ?? 0.0).toDouble(),
            category: data['category'] ?? '',
            subcategory: data['subcategory'] ?? '',
            imageUrls: List<String>.from(data['imageUrls'] ?? []), // Handle list of URLs
            stock: (data['stock'] ?? 0).toInt(),
            createdAt: data['createdAt'] ?? Timestamp.now(),
            updatedAt: data['updatedAt'] ?? Timestamp.now(),
            ageGroup: data['ageGroup'],
            gender: data['gender'],
          );
        }
      
        Map<String, dynamic> toMap() {
          return {
            'name': name,
            'description': description,
            'price': price,
            'category': category,
            'subcategory': subcategory,
            'imageUrls': imageUrls, // Store list of URLs
            'stock': stock,
            'createdAt': createdAt,
            'updatedAt': updatedAt,
            'ageGroup': ageGroup,
            'gender': gender,
          };
        }
      }