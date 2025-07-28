      import 'package:cloud_firestore/cloud_firestore.dart';
      
      class Category {
        final String id;
        final String name;
        final String imageUrl;
        final List<String> subcategories;
      
        Category({
          required this.id,
          required this.name,
          required this.imageUrl,
          this.subcategories = const [],
        });
      
        factory Category.fromFirestore(DocumentSnapshot doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Category(
            id: doc.id,
            name: data['name'] ?? '',
            imageUrl: data['imageUrl'] ?? '',
            subcategories: List<String>.from(data['subcategories'] ?? []),
          );
        }
      
        Map<String, dynamic> toMap() {
          return {
            'name': name,
            'imageUrl': imageUrl,
            'subcategories': subcategories,
          };
        }
      }