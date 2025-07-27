import 'package:flutter/material.dart';
import 'package:myapp/widgets/product_search_delegate.dart'; // Import the search delegate
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:myapp/models/banner.dart' as model;
import 'package:myapp/models/category.dart';
import 'package:myapp/services/banner_service.dart';
import 'package:myapp/services/category_service.dart';
import 'package:myapp/services/product_service.dart'; // Import ProductService
import 'package:myapp/screens/product_list_by_category_screen.dart'; // Import for category navigation
// Import other screens as needed for banner navigation
import 'package:myapp/screens/product_list_by_subcategory_screen.dart'; // Import for subcategory navigation
import 'package:myapp/models/product.dart'; // Import Product model
import 'package:myapp/screens/product_detail_screen.dart'; // Import ProductDetailScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategoryForSub = null; // Track selected category for subcategories display

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    // TODO: Implement product search logic based on the query
  }

  void _navigateToTargetScreen(String? targetScreen) {
    if (targetScreen == null) return;

    switch (targetScreen) {
      case 'productDetail':
        // TODO: Navigate to Product Detail screen (you'll need to pass product ID)
        // Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(productId: 'some_id')));
        break;
      case 'categoryList':
        // TODO: Navigate to Category List screen
         // Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryListScreen()));
        break;
       case 'promoPage':
        // TODO: Navigate to a Promotional Page
         // Navigator.push(context, MaterialPageRoute(builder: (context) => PromotionalPage()));
        break;
      // Add more cases for other target screens as needed
      default:
        print('Unknown target screen: $targetScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bannerService = Provider.of<BannerService>(context);
    final categoryService = Provider.of<CategoryService>(context);
    final productService = Provider.of<ProductService>(context); // Access ProductService

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Awesome App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(productService: productService), // Pass ProductService
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // Banner Carousel
          StreamBuilder<List<model.Banner>>(
            stream: bannerService.getBanners(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error loading banners: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final banners = snapshot.data ?? [];
              if (banners.isEmpty) {
                return const SizedBox.shrink(); // Hide if no banners
              }
              return CarouselSlider(
                options: CarouselOptions(
                  height: 200.0,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  aspectRatio: 16 / 9,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  viewportFraction: 0.8,
                ),
                items: banners.map((banner) {
                  return Builder(
                    builder: (BuildContext context) {
                      return GestureDetector(
                         onTap: () => _navigateToTargetScreen(banner.targetScreen), // Navigate on tap
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                             borderRadius: BorderRadius.circular(8.0),
                             image: DecorationImage(
                              image: NetworkImage(banner.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 20),
          // Categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Categories',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          const SizedBox(height: 10),
          StreamBuilder<List<Category>>(
            stream: categoryService.getCategories(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error loading categories: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final categories = snapshot.data ?? [];
              if (categories.isEmpty) {
                return const SizedBox.shrink(); // Hide if no categories
              }
              return SizedBox(
                height: 100, // Adjust height as needed
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return GestureDetector(
                      onTap: () {
                         setState(() {
                           _selectedCategoryForSub = category.name; // Select category to show subcategories
                         });
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(child: Text(category.name)),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          // Sub-categories display based on selected category
          if (_selectedCategoryForSub != null) // Only show if a category is selected
            StreamBuilder<List<String>>(
              stream: Stream.fromFuture(categoryService.getSubcategoriesForCategory(_selectedCategoryForSub!)),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading subcategories: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                 final subcategories = snapshot.data ?? [];
                 if (subcategories.isEmpty) {
                  return const SizedBox.shrink(); // Hide if no subcategories
                 }
                 return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 16.0),
                       child: Text(
                         'Subcategories for $_selectedCategoryForSub',
                         style: Theme.of(context).textTheme.headline6,
                       ),
                     ),
                     const SizedBox(height: 10),
                     SizedBox(
                       height: 50, // Adjust height as needed
                       child: ListView.builder(
                         scrollDirection: Axis.horizontal,
                         itemCount: subcategories.length,
                         itemBuilder: (context, index) {
                           final subcategory = subcategories[index];
                           return GestureDetector(
                             onTap: () {
                               // Navigate to a screen displaying products for this subcategory
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ProductListBySubcategoryScreen(categoryName: _selectedCategoryForSub!, subcategoryName: subcategory)));
                             },
                             child: Card(
                               margin: const EdgeInsets.symmetric(horizontal: 8.0),
                               child: Padding(
                                 padding: const EdgeInsets.all(8.0),
                                 child: Center(child: Text(subcategory)),
                               ),
                             ),
                           );
                         },
                       ),
                     ),
                   ],
                 );
              },
            ),

          const SizedBox(height: 20),
          // Product Listing (Display all products)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'All Products',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          const SizedBox(height: 10),
          StreamBuilder<List<Product>>(
            stream: productService.getProducts(), // Fetch all products
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error loading products: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final products = snapshot.data ?? [];

              if (products.isEmpty) {
                return const Center(child: Text('No products available.'));
              }

              return ListView.builder(
                shrinkWrap: true, // Important for ListView inside ListView
                physics: const NeverScrollableScrollPhysics(), // Disable scrolling for this inner ListView
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
                    onTap: () {
                      // Navigate to product detail screen
                       Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(productId: product.id)));
                    },
                  );
                },
              );
            },
          ),
           const SizedBox(height: 20),
        ],
      ),
    );
  }
}
