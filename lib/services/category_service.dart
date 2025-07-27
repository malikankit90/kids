import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/category.dart';
import 'package:myapp/services/firestore_service.dart';

class CategoryService {
  final FirestoreService _firestoreService = FirestoreService();
  final String _collectionPath = 'categories';

  // Fetch all categories
  Stream<List<Category>> getCategories() {
    return _firestoreService.getCollection(_collectionPath).map((snapshot) {
      // Sort categories by name or a dedicated order field if you add one
      List<Category> categories = snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
      categories.sort((a, b) => a.name.compareTo(b.name));
      return categories;
    });
  }

   // Add a new category
  Future<DocumentReference> addCategory(Category category) async {
    return await _firestoreService.addDocument(
        _collectionPath, category.toFirestore());
  }

  // Update an existing category
  Future<void> updateCategory(Category category) async {
    return await _firestoreService.updateDocument(
        '$_collectionPath/${category.id}', category.toFirestore());
  }

  // Delete a category by ID
  Future<void> deleteCategory(String id) async {
    return await _firestoreService.deleteDocument('$_collectionPath/$id');
  }

  // Fetch subcategories for a given category name
  Future<List<String>> getSubcategoriesForCategory(String categoryName) async {
    QuerySnapshot snapshot = await _firestoreService.getCollection(_collectionPath)
        .where('name', isEqualTo: categoryName)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      Category category = Category.fromFirestore(snapshot.docs.first);
      return category.subcategories;
    } else {
      return []; // Return empty list if category not found
    }
  }
}
