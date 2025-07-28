      import 'package:flutter/material.dart';
      import 'package:provider/provider.dart';
      import 'package:myapp/models/product.dart';
      import 'package:myapp/services/product_service.dart';

      class ProductDetailScreen extends StatefulWidget {
        final String productId;

        const ProductDetailScreen({super.key, required this.productId});

        @override
        _ProductDetailScreenState createState() => _ProductDetailScreenState();
      }

      class _ProductDetailScreenState extends State<ProductDetailScreen> {
        Product? _product;
        List<Product> _relatedProducts = [];
        bool _isLoading = true;
        String _errorMessage = '';

        @override
        void initState() {
          super.initState();
          _fetchProductDetails();
        }

        Future<void> _fetchProductDetails() async {
          try {
            setState(() {
              _isLoading = true;
              _errorMessage = '';
            });

            final productService = Provider.of<ProductService>(context, listen: false);
            final product = await productService.getProductById(widget.productId);

            if (product != null) {
              setState(() {
                _product = product;
              });
              // Fetch related products after getting the product details
              _fetchRelatedProducts(product.category, product.id);
            } else {
              setState(() {
                _errorMessage = 'Product not found.';
                _isLoading = false;
              });
            }
          } catch (e) {
            setState(() {
              _errorMessage = 'Error fetching product details: ${e.toString()}';
              _isLoading = false;
            });
          }
        }

        Future<void> _fetchRelatedProducts(String categoryId, String currentProductId) async {
           try {
             final productService = Provider.of<ProductService>(context, listen: false);
             final relatedProducts = await productService.getRelatedProducts(categoryId, currentProductId);
              setState(() {
                _relatedProducts = relatedProducts;
                _isLoading = false;
              });
           } catch (e) {
             setState(() {
                _errorMessage = 'Error fetching related products: ${e.toString()}';
                _isLoading = false;
             });
           }
        }

        @override
        Widget build(BuildContext context) {
          if (_isLoading) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Product Details'),
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (_errorMessage.isNotEmpty) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Product Details'),
              ),
              body: Center(
                child: Text(_errorMessage),
              ),
            );
          }

          if (_product == null) {
             return Scaffold(
              appBar: AppBar(
                title: const Text('Product Details'),
              ),
              body: const Center(
                child: Text('Product data is not available.'),
              ),
            );
          }

          // Display product details and related products
          return Scaffold(
            appBar: AppBar(
              title: Text(_product!.name),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Images Carousel
                    if (_product!.imageUrls.isNotEmpty)
                      SizedBox(
                        height: 250,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _product!.imageUrls.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Image.network(
                                _product!.imageUrls[index],
                                width: 250,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error, color: Colors.red, size: 50);
                                },
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        height: 250,
                        color: Colors.grey[300],
                        child: const Center(child: Text('No Image Available')),
                      ),

                    const SizedBox(height: 20),

                    // Product Details
                    Text(
                      _product!.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Price: ${_product!.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.green[700]),
                    ),
                    const SizedBox(height: 8),
                     Text(
                      'Stock: ${_product!.stock}',
                       style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _product!.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 20),

                    // Add to Cart Button
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement Add to Cart functionality
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Add to Cart button pressed!'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Add to Cart'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Related Products Section
                    Text(
                      'Related Products',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),

                    if (_relatedProducts.isNotEmpty)
                      SizedBox(
                        height: 200, // Adjust height as needed
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _relatedProducts.length,
                          itemBuilder: (context, index) {
                            final relatedProduct = _relatedProducts[index];
                            return GestureDetector(
                              onTap: () {
                                // Navigate to the detail screen of the related product
                                 Navigator.pushReplacement(
                                   context,
                                   MaterialPageRoute(
                                     builder: (context) => ProductDetailScreen(productId: relatedProduct.id),
                                   ),
                                 );
                              },
                              child: Card(
                                elevation: 2.0,
                                child: Container(
                                  width: 150, // Adjust width as needed
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Image.network(
                                          relatedProduct.imageUrls.isNotEmpty ? relatedProduct.imageUrls.first : 'https://via.placeholder.com/150',
                                          fit: BoxFit.cover,
                                           loadingBuilder: (context, child, loadingProgress) {
                                             if (loadingProgress == null) return child;
                                             return Center(
                                               child: CircularProgressIndicator(
                                                 value: loadingProgress.expectedTotalBytes != null
                                                     ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                     : null,
                                               ),
                                             );
                                           },
                                           errorBuilder: (context, error, stackTrace) {
                                             return const Icon(Icons.error, color: Colors.red);
                                           },
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        relatedProduct.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.titleSmall,
                                      ),
                                      Text(
                                        relatedProduct.price.toStringAsFixed(2),
                                        style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.green[700]),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      const Text('No related products found.'),
                  ],
                ),
              ),
            ),
          );
        }
      }