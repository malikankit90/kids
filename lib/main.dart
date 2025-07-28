import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/firebase_options.dart';
import 'dart:developer'; // Import for logging
import 'package:go_router/go_router.dart'; // Import go_router

import 'package:myapp/screens/auth_screen.dart'; // Import the actual AuthScreen
import 'package:myapp/screens/home_screen.dart'; // Import the actual HomeScreen
// Import the actual Admin Product List Screen
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/banner_service.dart';
import 'package:myapp/services/category_service.dart';
// Import the actual Admin Product List Screen
import 'package:myapp/services/firestore_service.dart'; // Import FirestoreService
import 'package:myapp/services/product_service.dart';
import 'package:myapp/services/user_role_provider.dart';
import 'package:myapp/screens/loading_screen.dart';

// Placeholder screens for admin
class AdminScreenPlaceholder extends StatelessWidget {
  const AdminScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    log('Building AdminScreenPlaceholder...'); // Added logging
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: const Center(child: Text('Admin Content Here')),
    );
  }
}

void main() async {
  print('TEST: Logging is working!'); // Added test print statement
  WidgetsFlutterBinding.ensureInitialized();
  log('Firebase initializing...'); // Added logging
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  log('Firebase initialized.'); // Added logging

  // Set up error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    log('Caught a Flutter error: ${details.exception}', error: details.exception, stackTrace: details.stack);
  };

  runApp(const MyApp()); // Running the MyApp widget
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    log('Building MyApp...'); // Added logging
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<UserRoleProvider>(create: (_) => UserRoleProvider()),
        Provider(create: (_) => BannerService()),
        Provider(create: (_) => CategoryService()),
        Provider(create: (_) => ProductService()),
        Provider(create: (_) => FirestoreService()),
        // Provide the authentication state changes stream
        StreamProvider<User?>(
          create: (context) => FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ),
      ],
      child: Builder( // Use Builder to get a context that has the providers
        builder: (context) {
          final router = GoRouter(
            routes: <RouteBase>[
              GoRoute(
                path: '/',
                builder: (BuildContext context, GoRouterState state) {
                  return const HomeScreen();
                },
              ),
              GoRoute(
                path: '/loading',
                builder: (BuildContext context, GoRouterState state) => const LoadingScreen(),
              ),
              GoRoute(
                path: '/admin',
                builder: (BuildContext context, GoRouterState state) {
                  return const AdminScreenPlaceholder(); // Admin page
                },
              ),
               GoRoute(
                path: '/auth',
                builder: (BuildContext context, GoRouterState state) {
                  return const AuthScreen(); // Auth screen
                },
              ),
            ],
             redirect: (BuildContext context, GoRouterState state) {
              // Watch the authentication state stream
              final user = context.watch<User?>();
              final isAuthenticated = user != null;
              final isGoingToAuth = state.uri.toString() == '/auth';
              
              log('GoRouter Redirect: path = ${state.uri}, isAuthenticated = $isAuthenticated'); // Added logging

              // If not authenticated, redirect to auth screen.
              if (!isAuthenticated) {
                return isGoingToAuth ? null : '/auth';
              }

              // If authenticated and trying to go to auth, redirect to home.
              if (isGoingToAuth) {
                return '/'; // Redirect to home screen
              }

              // Allow navigation to the loading screen if authenticated.
              if (state.uri.toString() == '/loading') {
                 return null;
              }

              // For all other authenticated routes, allow navigation.
              return null; // Allow navigation to the requested path
            },
          );

          return MaterialApp.router(
            routerConfig: router,
            title: 'E-commerce App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              useMaterial3: true,
            ),
          );
        }
      )
    );
  }
}
