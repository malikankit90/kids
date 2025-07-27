import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/product.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:myapp/services/storage_service.dart';

class ProductService {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final String _collectionPath = 'products';

  // Fetch all products
  Stream<List<Product>> getProducts() {
    return _firestoreService.getCollection(_collectionPath).map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  // Fetch a single product by ID
  Future<Product?> getProductById(String id) async {
    DocumentSnapshot doc = await _firestoreService.getDocument('$_collectionPath/$id');
    if (doc.exists) {
      return Product.fromFirestore(doc);
    } else {
      return null;
    }
  }

  // Add a new product with image uploads
  Future<DocumentReference> addProduct(Product product, List<String> imagePaths) async {
    List<String> imageUrls = [];
    for (String imagePath in imagePaths) {
      // Assuming imagePath is a local file path
      String downloadUrl = await _storageService.uploadImage(
          File(imagePath), 'products/${DateTime.now().millisecondsSinceEpoch}_${imagePath.split('/').last}');
      imageUrls.add(downloadUrl);
    }

    // Create a new Product object with image URLs
    Product newProduct = Product(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      category: product.category,
      subCategory: product.subCategory,
      images: imageUrls, // Use uploaded image URLs
      stock: product.stock,
      ageGroup: product.ageGroup,
      gender: product.gender,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    return await _firestoreService.addDocument(
        _collectionPath, newProduct.toFirestore());
  }

  // Update an existing product with potential new image uploads and deletions
  Future<void> updateProduct(Product product, {List<String>? newImagePaths, List<String>? imagesToDelete}) async {
     List<String> imageUrls = product.images; // Start with existing images

    // Upload new images
    if (newImagePaths != null) {
      for (String imagePath in newImagePaths) {
         // Assuming imagePath is a local file path
        String downloadUrl = await _storageService.uploadImage(
            File(imagePath), 'products/${DateTime.now().millisecondsSinceEpoch}_${imagePath.split('/').last}');
        imageUrls.add(downloadUrl);
      }
    }

    // Delete images
    if (imagesToDelete != null) {
      for (String imageUrl in imagesToDelete) {
        await _storageService.deleteImage(imageUrl);
        imageUrls.remove(imageUrl); // Remove from the list
      }
    }

     // Create an updated Product object with final image URLs
    Product updatedProduct = Product(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      category: product.category,
      subCategory: product.subCategory,
      images: imageUrls, // Use the updated list of image URLs
      stock: product.stock,
      ageGroup: product.ageGroup,
      gender: product.gender,
      createdAt: product.createdAt, // Keep original createdAt
      updatedAt: Timestamp.now(),
    );

    return await _firestoreService.updateDocument(
        '$_collectionPath/${product.id}', updatedProduct.toFirestore());
  }

  // Delete a product by ID and its associated images
  Future<void> deleteProduct(String id) async {
    // Get the product first to get image URLs
    Product? product = await getProductById(id);
    if (product != null) {
      // Delete images from storage
      for (String imageUrl in product.images) {
        await _storageService.deleteImage(imageUrl);
      }
      // Delete the product document from Firestore
      return await _firestoreService.deleteDocument('$_collectionPath/$id');
    }
  }

  // Fetch products by category
   Stream<List<Product>> getProductsByCategory(String category) {
    return _firestoreService.getCollection(_collectionPath)
        .where('category', isEqualTo: category)
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .toList();
    });
  }

  // Fetch products by category and subcategory
   Stream<List<Product>> getProductsBySubcategory(String category, String subcategory) {
    return _firestoreService.getCollection(_collectionPath)
        .where('category', isEqualTo: category)
        .where('subCategory', isEqualTo: subcategory)
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .toList();
    });
  }
}
