      import 'package:flutter/material.dart';
      import 'package:cached_network_image/cached_network_image.dart';
      import 'package:myapp/models/product.dart';
      import 'package:myapp/screens/product_detail_screen.dart';
      
      class ProductSearchDelegate extends SearchDelegate<Product?> {
        final List<Product> products;
      
        ProductSearchDelegate(this.products);
      
        @override
        List<Widget>? buildActions(BuildContext context) {
          return [
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                query = '';
                showSuggestions(context);
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
          final results = products.where(
            (product) => product.name.toLowerCase().contains(query.toLowerCase()),
          );
      
          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final product = results.elementAt(index);
              return ListTile(
                leading: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                title: Text(product.name),
                subtitle: Text('$${product.price.toStringAsFixed(2)}'), // Interpolation fixed
                onTap: () {
                   Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)));
                },
              );
            },
          );
        }
      
        @override
        Widget buildSuggestions(BuildContext context) {
          final suggestions = products.where(
            (product) => product.name.toLowerCase().contains(query.toLowerCase()),
          );
          return ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final product = suggestions.elementAt(index);
              return ListTile(
                title: Text(product.name),
                onTap: () {
                  query = product.name;
                  showResults(context);
                },
              );
            },
          );
        }
      }