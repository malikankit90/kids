      import 'package:flutter/material.dart';
      import 'package:provider/provider.dart';
      import 'package:cached_network_image/cached_network_image.dart';
      import 'package:myapp/models/product.dart';
      import 'package:myapp/services/product_service.dart';
      import 'package:myapp/screens/admin/edit_product_screen.dart';
      
      class AdminProductListScreen extends StatelessWidget {
        const AdminProductListScreen({super.key});
      
        @override
        Widget build(BuildContext context) {
          final productService = Provider.of<ProductService>(context);
      
          return Scaffold(
            appBar: AppBar(
              title: const Text('Admin Products'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    // Navigate to EditProductScreen for adding a new product
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProductScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: StreamBuilder<List<Product>>(
              stream: productService.getAllProducts(), // Assuming you have a method to get all products
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
      
                final products = snapshot.data ?? [];
      
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                     // Use a placeholder image if product.imageUrl is null or empty
                    final imageUrl = (product.imageUrl != null && product.imageUrl!.isNotEmpty) ? product.imageUrl! : 'https://via.placeholder.com/50';
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        leading: CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                        title: Text(product.name),
                        subtitle: Text(product.price.toStringAsFixed(2)), // Interpolation fixed
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                // Navigate to EditProductScreen for editing an existing product
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProductScreen(product: product),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                // Implement delete functionality
                                try {
                                  await productService.deleteProduct(product.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Product ${product.name} deleted')),
                                  );
                                } catch (e) {
                                   ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to delete product: $e')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        }
      }
