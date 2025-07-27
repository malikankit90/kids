import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/product.dart';
import 'package:myapp/services/product_service.dart';

class ProductListByCategoryScreen extends StatelessWidget {
  final String categoryName;

  const ProductListByCategoryScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Products in $categoryName'),
      ),
      body: StreamBuilder<List<Product>>(
        stream: productService.getProductsByCategory(categoryName),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return Center(child: Text('No products found in $categoryName.'));
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
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
                // TODO: Add onTap to navigate to product detail screen
              );
            },
          );
        },
      ),
    );
  }
}
