      import 'dart:io';
      import 'package:cloud_firestore/cloud_firestore.dart';
      import 'package:firebase_storage/firebase_storage.dart';
      import 'package:myapp/models/product.dart';
      import '../screens/product_list_screen.dart';
      import 'package:path/path.dart' as path; // Import path package
      
      class ProductService {
        final FirebaseFirestore _firestore = FirebaseFirestore.instance;
        final FirebaseStorage _storage = FirebaseStorage.instance;
      
        // Method to get products with filtering, sorting, and pagination
        Future<List<Product>> getProducts({
          String? category,
          String? subcategory,
          double? minPrice,
          double? maxPrice,
          String? ageGroup,
          String? gender,
          ProductSortingOption sortingOption = ProductSortingOption.newest,
          DocumentSnapshot? startAfterDocument,
          int limit = 10,
        }) async {
          try {
            Query query = _firestore.collection('products');

            // Apply filters
            if (category != null && category.isNotEmpty) {
              query = query.where('category', isEqualTo: category);
            }
            if (subcategory != null && subcategory.isNotEmpty) {
              query = query.where('subcategory', isEqualTo: subcategory);
            }
            if (minPrice != null) {
              query = query.where('price', isGreaterThanOrEqualTo: minPrice);
            }
            if (maxPrice != null) {
              query = query.where('price', isLessThanOrEqualTo: maxPrice);
            }
             if (ageGroup != null && ageGroup.isNotEmpty) {
              query = query.where('ageGroup', isEqualTo: ageGroup);
            }
            if (gender != null && gender.isNotEmpty) {
              query = query.where('gender', isEqualTo: gender);
            }
      
            // Apply sorting
            switch (sortingOption) {
              case ProductSortingOption.newest:
                query = query.orderBy('createdAt', descending: true);
                break;
              case ProductSortingOption.priceLowToHigh:
                query = query.orderBy('price', descending: false);
                 query = query.orderBy('createdAt', descending: true);
                break;
              case ProductSortingOption.priceHighToLow:
                query = query.orderBy('price', descending: true);
                 query = query.orderBy('createdAt', descending: true);
                break;
            }

            // Apply pagination
            if (startAfterDocument != null) {
              query = query.startAfterDocument(startAfterDocument);
            }
            query = query.limit(limit);

            final querySnapshot = await query.get();

            return querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();

          } catch (e) {
            print('Error getting products with filters/sorting/pagination: $e');
            rethrow;
          }
        }

         // Method to get the last document from a query snapshot for pagination
         Future<DocumentSnapshot?> getLastDocument({
          String? category,
          String? subcategory,
          double? minPrice,
          double? maxPrice,
          String? ageGroup,
          String? gender,
          ProductSortingOption sortingOption = ProductSortingOption.newest,
          DocumentSnapshot? startAfterDocument,
          int limit = 10,
        }) async {
           try {
            Query query = _firestore.collection('products');

            // Apply filters
            if (category != null && category.isNotEmpty) {
              query = query.where('category', isEqualTo: category);
            }
            if (subcategory != null && subcategory.isNotEmpty) {
              query = query.where('subcategory', isEqualTo: subcategory);
            }
            if (minPrice != null) {
              query = query.where('price', isGreaterThanOrEqualTo: minPrice);
            }
            if (maxPrice != null) {
              query = query.where('price', isLessThanOrEqualTo: maxPrice);
            }
             if (ageGroup != null && ageGroup.isNotEmpty) {
              query = query.where('ageGroup', isEqualTo: ageGroup);
            }
            if (gender != null && gender.isNotEmpty) {
              query = query.where('gender', isEqualTo: gender);
            }
      
            // Apply sorting
            switch (sortingOption) {
              case ProductSortingOption.newest:
                query = query.orderBy('createdAt', descending: true);
                break;
              case ProductSortingOption.priceLowToHigh:
                query = query.orderBy('price', descending: false);
                 query = query.orderBy('createdAt', descending: true);
                break;
              case ProductSortingOption.priceHighToLow:
                query = query.orderBy('price', descending: true);
                 query = query.orderBy('createdAt', descending: true);
                break;
            }

             // Apply pagination
            if (startAfterDocument != null) {
              query = query.startAfterDocument(startAfterDocument);
            }
            query = query.limit(limit);

            final querySnapshot = await query.get();

             if (querySnapshot.docs.isNotEmpty) {
              return querySnapshot.docs.last;
            } else {
              return null;
            }

           } catch (e) {
            print('Error getting last document: $e');
            return null;
           }
        }

        Stream<List<Product>> getAllProducts() {
          return _firestore.collection('products').snapshots().map((snapshot) {
            return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
          });
        }
      
        Future<void> addProduct(Product product, List<File> images) async {
          try {
            // Upload new images and get their download URLs
            final imageUrls = await Future.wait(images.map((image) => _uploadImage(image)));

            final newProduct = Product(
              id: '',
              name: product.name,
              description: product.description,
              price: product.price,
              category: product.category,
              subcategory: product.subcategory,
              imageUrls: imageUrls, // Store uploaded image URLs
              stock: product.stock,
              createdAt: Timestamp.now(),
              updatedAt: Timestamp.now(),
              ageGroup: product.ageGroup,
              gender: product.gender,
            );
            await _firestore.collection('products').add(newProduct.toMap());
          } catch (e) {
            print('Error adding product: $e');
            rethrow;
          }
        }
      
        Future<void> updateProduct(Product product, {List<File>? newImages, List<String>? imagesToDelete}) async {
          try {
             // Delete images marked for deletion from Storage
            if (imagesToDelete != null && imagesToDelete.isNotEmpty) {
              await Future.wait(imagesToDelete.map((imageUrl) => _deleteImage(imageUrl)));
            }

            // Upload new images and get their download URLs
            final newImageUrls = (newImages != null && newImages.isNotEmpty)
                ? await Future.wait(newImages.map((image) => _uploadImage(image)))
                : <String>[];

            // Combine existing and new image URLs
            final updatedImageUrls = [...product.imageUrls, ...newImageUrls];

            final updatedProduct = Product(
              id: product.id,
              name: product.name,
              description: product.description,
              price: product.price,
              category: product.category,
              subcategory: product.subcategory,
              imageUrls: updatedImageUrls, // Update with combined list
              stock: product.stock,
              createdAt: product.createdAt,
              updatedAt: Timestamp.now(),
              ageGroup: product.ageGroup,
              gender: product.gender,
            );

            await _firestore.collection('products').doc(product.id).update(updatedProduct.toMap());
          } catch (e) {
            print('Error updating product: $e');
            rethrow;
          }
        }
      
        Future<void> deleteProduct(String id) async {
          try {
            // Get product to delete images from storage
            final productDoc = await _firestore.collection('products').doc(id).get();
            if (productDoc.exists) {
              final product = Product.fromFirestore(productDoc);
               // Delete images from storage
              if (product.imageUrls.isNotEmpty) {
                await Future.wait(product.imageUrls.map((imageUrl) => _deleteImage(imageUrl)));
              }
               // Delete product document from Firestore
              await _firestore.collection('products').doc(id).delete();
            }
          } catch (e) {
            print('Error deleting product: $e');
            rethrow;
          }
        }
      
        Future<String> _uploadImage(File imageFile) async {
          try {
            final fileName = 'products/${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
            final ref = _storage.ref().child(fileName);
            final uploadTask = ref.putFile(imageFile);
            final snapshot = await uploadTask.whenComplete(() => null);
            final downloadUrl = await snapshot.ref.getDownloadURL();
            return downloadUrl;
          } catch (e) {
            print('Error uploading image: $e');
            rethrow;
          }
        }

         Future<void> _deleteImage(String imageUrl) async {
           try {
             final ref = _storage.refFromURL(imageUrl);
             await ref.delete();
           } catch (e) {
              // Handle the case where the file doesn't exist or other errors
             print('Error deleting image: $e');
             // Continue with the rest of the process even if image deletion fails
           }
         }
      
        Future<List<Product>> getFeaturedProducts() async {
           try {
            final querySnapshot = await _firestore
                .collection('products')
                 // Add a field to indicate featured products, or use a different collection
                .limit(10)
                .get();
            return querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
          } catch (e) {
            print('Error getting featured products: $e');
            return [];
          }
        }
      
         Future<List<Product>> getRecentProducts() async {
           try {
            final querySnapshot = await _firestore
                .collection('products')
                .orderBy('createdAt', descending: true)
                .limit(10)
                .get();
            return querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
          } catch (e) {
            print('Error getting recent products: $e');
            return [];
          }
        }
      
         Future<List<Product>> getProductsByCategory(String category) async {
          try {
            final querySnapshot = await _firestore
                .collection('products')
                .where('category', isEqualTo: category)
                .get();
            return querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
          } catch (e) {
            print('Error getting products by category: $e');
            return [];
          }
        }
      
         Future<List<Product>> getProductsBySubCategory(String category, String subcategory) async {
          try {
            final querySnapshot = await _firestore
                .collection('products')
                .where('category', isEqualTo: category)
                .where('subcategory', isEqualTo: subcategory)
                .get();
            return querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
          } catch (e) {
            print('Error getting products by subcategory: $e');
            return [];
          }
        }

        // New method to get related products by category (excluding the current product)
        Future<List<Product>> getRelatedProducts(String categoryId, String currentProductId) async {
          try {
            final querySnapshot = await _firestore
                .collection('products')
                .where('category', isEqualTo: categoryId)
                .limit(5) // Limit the number of related products
                .get();

            // Filter out the current product
            return querySnapshot.docs
                .map((doc) => Product.fromFirestore(doc))
                .where((product) => product.id != currentProductId)
                .toList();
          } catch (e) {
            print('Error getting related products: $e');
            return [];
          }
        }

         Future<Product?> getProductById(String id) async {
           try {
             final docSnapshot = await _firestore.collection('products').doc(id).get();
             if (docSnapshot.exists) {
               return Product.fromFirestore(docSnapshot);
             } else {
               return null;
             }
           } catch (e) {
             print('Error getting product by ID: $e');
             return null;
           }
         }

           // Method to search for products by name or description
         Future<List<Product>> searchProducts(String query) async {
           try {
             // This is a basic example, a more advanced search might require a dedicated search service (e.g., Algolia)
             final querySnapshot = await _firestore
                 .collection('products')
                 .where('name', isGreaterThanOrEqualTo: query)
                 .where('name', isLessThanOrEqualTo: '$query')
                 .get();

             final products = querySnapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();

             // You might also want to search in description, which would require a separate query or a different approach

             return products;
           } catch (e) {
             print('Error searching products: $e');
             return [];
           }
         }
      }