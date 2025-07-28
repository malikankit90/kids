      import 'package:flutter/material.dart';
      import 'package:provider/provider.dart';
      import 'package:cached_network_image/cached_network_image.dart';
      import 'package:myapp/models/product.dart';
      import 'package:myapp/services/product_service.dart';
      // Removed import 'package:myapp/widgets/custom_app_bar.dart';
      import 'package:myapp/screens/product_detail_screen.dart';
      import 'package:myapp/screens/home_screen.dart'; // Import HomeScreen for the stub

      class ProductListBySubcategoryScreen extends StatelessWidget {
        final String subcategoryName;

        const ProductListBySubcategoryScreen({
          super.key,
          required this.subcategoryName,
        });

        @override
        Widget build(BuildContext context) {
          final productService = Provider.of<ProductService>(context);

          return Scaffold(
            appBar: CustomAppBarStub(title: subcategoryName), // Using stub
            body: FutureBuilder<List<Product>>(
              future: productService.getProductsBySubcategory(subcategoryName), // Corrected method call
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No products found in this subcategory.'));
                } else {
                  final products = snapshot.data!;
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                       // Handle nullable imageUrl
                      final imageUrl = product.imageUrl ?? 'https://via.placeholder.com/50';
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: ListTile(
                          leading: CachedNetworkImage(
                            imageUrl: imageUrl, // Use the potentially placeholder imageUrl
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                          title: Text(product.name),
                          subtitle: Text(product.price.toStringAsFixed(2)),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                // Pass the product object to ProductDetailScreen
                                builder: (context) => ProductDetailScreen(product: product), // Corrected to pass product object
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          );
        }
      }