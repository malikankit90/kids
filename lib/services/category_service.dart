      import 'package:cloud_firestore/cloud_firestore.dart';
      import 'package:myapp/models/category.dart';
      
      class CategoryService {
        final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      
        Stream<List<Category>> getCategories() {
          return _firestore.collection('categories').snapshots().map((snapshot) {
            return snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
          });
        }
      
        Future<void> addCategory(Category category) {
          return _firestore.collection('categories').add(category.toMap());
        }
      
        Future<void> updateCategory(Category category) {
          return _firestore.collection('categories').doc(category.id).update(category.toMap());
        }
      
        Future<void> deleteCategory(String id) {
          return _firestore.collection('categories').doc(id).delete();
        }
      
        Future<Category?> getCategoryByName(String categoryName) async {
          try {
            final querySnapshot = await _firestore
                .collection('categories')
                .where('name', isEqualTo: categoryName) // Fixed Firestore query
                .limit(1)
                .get();
      
            if (querySnapshot.docs.isNotEmpty) {
              return Category.fromFirestore(querySnapshot.docs.first);
            } else {
              return null;
            }
          } catch (e) {
            print('Error getting category by name: $e');
            return null;
          }
        }

        // Added getSubcategoriesForCategory method
        Future<List<String>> getSubcategoriesForCategory(String categoryName) async {
           // TODO: Implement actual logic to fetch subcategories for the given category
           // This is a placeholder implementation
          print('Fetching subcategories for category: $categoryName');
          return Future.value([]); // Return an empty list for now
        }
      }