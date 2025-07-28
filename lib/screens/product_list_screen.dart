import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'product_detail_screen.dart'; // Import the product detail screen

// Enum for sorting options
enum ProductSortingOption {
  newest,
  priceLowToHigh,
  priceHighToLow,
}

// Provider for managing product list state, filters, sorting, and pagination
class ProductListProvider with ChangeNotifier {
  final ProductService _productService;
  List<Product> _products = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;

  // Filter criteria
  String? _selectedCategory;
  String? _selectedSubCategory;
  double? _minPrice;
  double? _maxPrice;
  String? _selectedAgeGroup;
  String? _selectedGender;

  // Sorting criteria
  ProductSortingOption _sortingOption = ProductSortingOption.newest;

  ProductListProvider(this._productService);

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  String? get selectedCategory => _selectedCategory;
  String? get selectedSubCategory => _selectedSubCategory;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  String? get selectedAgeGroup => _selectedAgeGroup;
  String? get selectedGender => _selectedGender;
  ProductSortingOption get sortingOption => _sortingOption;

  // Set initial category and subcategory
  void setCategories({String? category, String? subcategory}) {
    _selectedCategory = category;
    _selectedSubCategory = subcategory;
    resetPagination();
    fetchProducts();
  }

  // Set filters and refetch products
  void setFilters({double? minPrice, double? maxPrice, String? ageGroup, String? gender}) {
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _selectedAgeGroup = ageGroup;
    _selectedGender = gender;
    resetPagination();
    fetchProducts();
  }

  // Set sorting option and refetch products
  void setSortingOption(ProductSortingOption option) {
    _sortingOption = option;
    resetPagination();
    fetchProducts();
  }

  // Reset pagination state
  void resetPagination() {
    _products = [];
    _hasMore = true;
    _lastDocument = null;
  }

  // Fetch products based on current filters and sorting
  Future<void> fetchProducts() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newProducts = await _productService.getProducts(
        category: _selectedCategory,
        subcategory: _selectedSubCategory,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        ageGroup: _selectedAgeGroup,
        gender: _selectedGender,
        sortingOption: _sortingOption,
        startAfterDocument: _lastDocument,
        limit: 10, // Adjust limit as needed
      );

      if (newProducts.isEmpty) {
        _hasMore = false;
      } else {
        _products.addAll(newProducts);
        // Update the last document for pagination
        if (newProducts.isNotEmpty) {
           _lastDocument = await _productService.getLastDocument(
             category: _selectedCategory,
             subcategory: _selectedSubCategory,
             minPrice: _minPrice,
             maxPrice: _maxPrice,
             ageGroup: _selectedAgeGroup,
             gender: _selectedGender,
             sortingOption: _sortingOption,
             startAfterDocument: _lastDocument,
             limit: 10, // Use the same limit as fetchProducts
           );
        }
      }
    } catch (e) {
      print('Error fetching products: $e');
      _hasMore = false; // Stop loading more on error
    }

    _isLoading = false;
    notifyListeners();
  }
}

class ProductListScreen extends StatefulWidget {
  final String? category;
  final String? subcategory;

  const ProductListScreen({super.key, this.category, this.subcategory});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _scrollController = ScrollController();

  // Local state for price range slider
  RangeValues _priceRange = const RangeValues(0, 1000);

  @override
  void initState() {
    super.initState();
    // Fetch initial products when the screen is created
    Provider.of<ProductListProvider>(context, listen: false)
        .setCategories(category: widget.category, subcategory: widget.subcategory);

    // Add scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        // User has scrolled to the end, load more products
        Provider.of<ProductListProvider>(context, listen: false).fetchProducts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access the provider using Consumer or Provider.of with listen: true
    final productListProvider = Provider.of<ProductListProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subcategory ?? widget.category ?? 'Products'),
      ),
      body: Column(
        children: [
          // Filter and Sorting Options
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Sorting Dropdown
                DropdownButtonFormField<ProductSortingOption>(
                  decoration: const InputDecoration(
                    labelText: 'Sort By',
                    border: OutlineInputBorder(),
                  ),
                  value: productListProvider.sortingOption,
                  onChanged: (option) {
                    if (option != null) {
                      Provider.of<ProductListProvider>(context, listen: false).setSortingOption(option);
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: ProductSortingOption.newest, child: Text('Newest')),
                    DropdownMenuItem(value: ProductSortingOption.priceLowToHigh, child: Text('Price: Low to High')),
                    DropdownMenuItem(value: ProductSortingOption.priceHighToLow, child: Text('Price: High to Low')),
                  ],
                ),
                const SizedBox(height: 12),

                // Price Range Slider
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Price Range'),
                    RangeSlider(
                      values: _priceRange,
                      min: 0,
                      max: 1000, // Adjust max price as needed
                      divisions: 100, // Adjust divisions as needed
                      labels: RangeLabels(
                        _priceRange.start.round().toString(),
                        _priceRange.end.round().toString(),
                      ),
                      onChanged: (values) {
                        setState(() {
                          _priceRange = values;
                        });
                      },
                      onChangeEnd: (values) {
                         // Apply filter when the user stops dragging
                         Provider.of<ProductListProvider>(context, listen: false)
                            .setFilters(minPrice: values.start, maxPrice: values.end);
                      },
                    ),
                    Text('Range: \${_priceRange.start.round()} - \${_priceRange.end.round()}'),
                  ],
                ),
                const SizedBox(height: 12),

                // Age Group Dropdown (Example values)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Age Group',
                     border: OutlineInputBorder(),
                  ),
                  value: productListProvider.selectedAgeGroup, // Use provider state
                  onChanged: (value) {
                     Provider.of<ProductListProvider>(context, listen: false)
                        .setFilters(ageGroup: value);
                  },
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Age Groups')),
                    DropdownMenuItem(value: 'Kids', child: Text('Kids')),
                    DropdownMenuItem(value: 'Teen', child: Text('Teen')),
                    DropdownMenuItem(value: 'Adult', child: Text('Adult')),
                  ],
                ),
                 const SizedBox(height: 12),

                // Gender Dropdown (Example values)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                     border: OutlineInputBorder(),
                  ),
                   value: productListProvider.selectedGender, // Use provider state
                  onChanged: (value) {
                     Provider.of<ProductListProvider>(context, listen: false)
                        .setFilters(gender: value);
                  },
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Genders')),
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                    DropdownMenuItem(value: 'Unisex', child: Text('Unisex')),
                  ],
                ),
              ],
            ),
          ),

          // Product List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: productListProvider.products.length + (productListProvider.hasMore ? 1 : 0), // Add 1 for loading indicator
              itemBuilder: (context, index) {
                if (index < productListProvider.products.length) {
                  final product = productListProvider.products[index];
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text('\${product.price.toStringAsFixed(2)}'),
                     leading: product.imageUrl != null && product.imageUrl!.isNotEmpty
                         ? Image.network(product.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
                         : Container(width: 50, height: 50, color: Colors.grey), // Placeholder
                     onTap: () {
                       // Navigate to product detail screen
                       Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (context) => ProductDetailScreen(productId: product.id), // Navigate to detail screen
                         ),
                       );
                     },
                  );
                } else if (productListProvider.isLoading) {
                  // This is the loading indicator at the end of the list
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else {
                   // No more products and not loading
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
