      import 'package:flutter/material.dart';
      import 'package:carousel_slider/carousel_slider.dart';
      import 'package:cached_network_image/cached_network_image.dart';
      import 'package:provider/provider.dart'; // Import Provider

      import 'package:myapp/models/app_banner.dart'; // Renamed import
      import 'package:myapp/models/category.dart';
      import 'package:myapp/models/product.dart';
      import 'package:myapp/services/banner_service.dart';
      import 'package:myapp/services/category_service.dart';
      import 'package:myapp/services/product_service.dart';
      import 'package:myapp/services/auth_service.dart'; // Import AuthService
       import 'package:myapp/screens/product_list_screen.dart'; // Import the new product list screen

      // Removed import 'package:myapp/widgets/custom_app_bar.dart';
      // Removed import 'package:myapp/widgets/custom_drawer.dart';
      import 'package:myapp/screens/product_detail_screen.dart';
      // Removed import 'package:myapp/screens/product_list_by_category_screen.dart';
      // Removed import 'package:myapp/screens/product_list_by_subcategory_screen.dart';
      // Removed import 'package:myapp/screens/product_search_screen.dart';

      class HomeScreen extends StatefulWidget {
        const HomeScreen({super.key});

        @override
        _HomeScreenState createState() => _HomeScreenState();
      }

      class _HomeScreenState extends State<HomeScreen> {
        late Stream<List<AppBanner>> _bannersStream; // Changed to Stream and AppBanner
        late Stream<List<Category>> _categoriesStream; // Changed to Stream
        late Future<List<Product>> _featuredProductsFuture;
        late Future<List<Product>> _recentProductsFuture;

        @override
        void initState() {
          super.initState();
          _bannersStream = BannerService().getBanners(); // Assigned Stream
          _categoriesStream = CategoryService().getCategories(); // Assigned Stream
          _featuredProductsFuture = ProductService().getFeaturedProducts();
          _recentProductsFuture = ProductService().getRecentProducts();
        }

        @override
        Widget build(BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('E-commerce App'),
              actions: [
                 // Add the sign-out icon here
                IconButton(
                  icon: const Icon(Icons.logout), // Use a logout icon
                  onPressed: () async {
                    // Call the signOut method from AuthService
                    await Provider.of<AuthService>(context, listen: false).signOut();
                  },
                  tooltip: 'Sign Out',
                ),
              ],
            ), // Using a standard AppBar now
            drawer: CustomDrawerStub(), // Using stub
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for products...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                       readOnly: true,
                       onTap: () {
                         // Navigator.push(context, MaterialPageRoute(builder: (context) => ProductSearchScreen())); // Removed usage
                       },
                    ),
                  ),
                  _buildBannerSection(),
                  _buildCategorySection(),
                  _buildFeaturedProductsSection(),
                  _buildRecentProductsSection(),
                ],
              ),
            ),
          );
        }

        Widget _buildBannerSection() {
          return StreamBuilder<List<AppBanner>>( // Changed to StreamBuilder and AppBanner
            stream: _bannersStream, // Used Stream
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading banners'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SizedBox.shrink();
              } else {
                final banners = snapshot.data!;
                return CarouselSlider.builder(
                  itemCount: banners.length,
                  itemBuilder: (context, index, realIndex) {
                    final banner = banners[index];
                    // Add null or empty check for banner.imageUrl
                    final imageUrl = (banner.imageUrl.isNotEmpty) ? banner.imageUrl : 'https://via.placeholder.com/400x200';
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ),
                      ),
                    );
                  },
                  options: CarouselOptions(
                    autoPlay: true,
                    enlargeCenterPage: true,
                    aspectRatio: 16 / 9,
                    enableInfiniteScroll: true,
                    viewportFraction: 0.8,
                  ),
                );
              }
            },
          );
        }

        Widget _buildCategorySection() {
          return StreamBuilder<List<Category>>( // Changed to StreamBuilder
            stream: _categoriesStream, // Used Stream
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading categories'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SizedBox.shrink();
              } else {
                final categories = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Categories',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            // Add null or empty check for category.imageUrl
                             final imageUrl = (category.imageUrl.isNotEmpty) ? category.imageUrl : 'https://via.placeholder.com/100';
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductListScreen(category: category.name), // Navigate to ProductListScreen
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundImage: CachedNetworkImageProvider(imageUrl), // Use the potentially placeholder imageUrl
                                    ),
                                    const SizedBox(height: 5),
                                    Text(category.name),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        }

        Widget _buildFeaturedProductsSection() {
          return FutureBuilder<List<Product>>(
            future: _featuredProductsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading featured products'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SizedBox.shrink();
              } else {
                final products = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Featured Products',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                           // Use a placeholder image if product.imageUrl is null or empty
                            final imageUrl = (product.imageUrl != null && product.imageUrl!.isNotEmpty) ? product.imageUrl! : 'https://via.placeholder.com/150';
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailScreen(productId: product.id), // Corrected constructor usage
                                  ),
                                );
                              },
                              child: SizedBox(
                                width: 150,
                                child: Card(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: CachedNetworkImage(
                                          imageUrl: imageUrl,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          placeholder: (context, url) => Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                          errorWidget: (context, url, error) => Icon(Icons.error),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              product.price.toStringAsFixed(2),
                                              style: TextStyle(color: Colors.green), // Interpolation fixed
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        }

        Widget _buildRecentProductsSection() {
          return FutureBuilder<List<Product>>(
            future: _recentProductsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading recent products'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SizedBox.shrink();
              } else {
                final products = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Products',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                           // Use a placeholder image if product.imageUrl is null or empty
                          final imageUrl = (product.imageUrl != null && product.imageUrl!.isNotEmpty) ? product.imageUrl! : 'https://via.placeholder.com/150';
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              leading: CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              ),
                              title: Text(product.name),
                              subtitle: Text(product.price.toStringAsFixed(2)), // Interpolation fixed
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailScreen(productId: product.id), // Corrected constructor usage
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }
            },
          );
        }
      }

      // Stub for CustomAppBar
      class CustomAppBarStub extends StatelessWidget implements PreferredSizeWidget {
        final String title;

        const CustomAppBarStub({super.key, required this.title});

        @override
        Size get preferredSize => const Size.fromHeight(kToolbarHeight);

        @override
        Widget build(BuildContext context) {
          return AppBar(
            title: Text(title),
          );
        }
      }

      // Stub for CustomDrawer
      class CustomDrawerStub extends StatelessWidget {
        const CustomDrawerStub({super.key});

        @override
        Widget build(BuildContext context) {
          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: const <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Text(
                    'Drawer Header (Stub)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.message),
                  title: Text('Messages'),
                ),
                ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('Profile'),
                ),
              ],
            ),
          );
        }
      }

      // Stub for ProductSearchScreen
      class ProductSearchScreenStub extends StatelessWidget {
         const ProductSearchScreenStub({super.key});

         @override
         Widget build(BuildContext context) {
           return Scaffold(
             appBar: AppBar(title: const Text('Product Search Screen (Stub)')),
             body: const Center(child: Text('Product Search Screen Placeholder')),
           );
         }
      }