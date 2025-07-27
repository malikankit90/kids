import 'package:flutter/material.dart';
import 'package:myapp/models/product.dart';
import 'package:myapp/services/product_service.dart';
import 'package:myapp/screens/product_detail_screen.dart'; // Import ProductDetailScreen

class ProductSearchDelegate extends SearchDelegate<Product?> {
  final ProductService productService;

  ProductSearchDelegate({required this.productService});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // This is called when the user presses enter on the search bar.
    // In our case, we'll show the same results as suggestions.
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Stream products from ProductService and filter based on the query
    return StreamBuilder<List<Product>>(
      stream: productService.getProducts(), // Fetch all products
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data ?? [];

        // Filter products client-side based on the query
        final filteredProducts = products.where((product) {
          return product.name.toLowerCase().contains(query.toLowerCase()) ||
                 product.category.toLowerCase().contains(query.toLowerCase()) ||
                 product.subCategory.toLowerCase().contains(query.toLowerCase()); // Add more fields if needed
        }).toList();

        if (filteredProducts.isEmpty) {
          return const Center(child: Text('No products found.'));
        }

        return ListView.builder(
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
            return ListTile(
              leading: product.images.isNotEmpty
                  ? Image.network(
                      product.images.first,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image),
              title: Text(product.name),
              subtitle: Text('$${product.price.toStringAsFixed(2)}'),
              onTap: () {
                // Navigate to product detail screen
                 Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(productId: product.id)));
              },
            );
          },
        );
      },
    );
  }
}
