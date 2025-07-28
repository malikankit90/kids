# Project Blueprint

## Overview

This document outlines the purpose, capabilities, and development progress of the Flutter e-commerce application. It tracks the changes made to the project, including style, design, features, and error resolutions.

## Project Outline

### Purpose and Capabilities

The project is an e-commerce application built with Flutter and Firebase. It aims to provide a platform for displaying products, categories, and banners, as well as handling user authentication and potentially administrative functions.

### Style and Design

- The application uses Material Design principles.
- Typography is updated to use the new Material Design 3 system (e.g., `titleLarge`).
- Image loading is handled with `cached_network_image` for better performance.
- Basic UI elements like `AppBar`, `Drawer`, `Card`, and `ListTile` are used for layout and content display.
- Interpolation syntax for displaying dynamic data in strings has been corrected.

### Features Implemented

- Displaying a list of products on the home screen.
- Displaying banners using a carousel slider.
- Displaying product categories.
- Navigation to product detail screens.
- Basic product search functionality (currently stubbed).
- Integration with Firebase Authentication.
- Integration with Firestore for fetching product, category, and banner data.
- **User Authentication (Email and Password):** Implemented a functional authentication screen allowing users to sign up and log in using their email and password, integrated with Firebase Authentication.
- **Admin Product Management:** Integrated the existing `AdminProductListScreen` to display products for administration. Implemented navigation for editing and deleting products, and adding new products.

### Errors Addressed

- **Interpolation Errors:** Corrected incorrect string interpolation syntax (`'$'{...}'` to `'${...}'`) in multiple files.
- **Missing Imports/Files:** Identified and removed imports for files that were not found (`auth_screen.dart`, `admin_home_screen.dart`, `custom_app_bar.dart`, `custom_drawer.dart`, `product_search_screen.dart`).
- **Undefined Widgets/Constructors:** Created stub implementations for `AuthScreen`, `AdminHomeScreen`, `CustomAppBar`, `CustomDrawer`, and `ProductSearchScreen` to allow the project to build.
- **Type Name Conflict:** Renamed the `Banner` model class to `AppBanner` to avoid conflict with the Flutter widget and refactored all its usages and imports.
- **Missing `toMap` Method:** Added `toMap` methods to the `Category` and `AppBanner` models for serialization to Firestore.
- **Firestore Query Syntax:** Corrected the syntax for Firestore queries (specifically the `isEqualTo` parameter).
- **File Class Usage:** Added the `dart:io` import and ensured correct usage of the `File` class in `ProductService`.
- **Null Safety:** Addressed null safety issues when accessing the `User` object from Firebase Authentication.
- **Typography:** Updated deprecated typography usage (e.g., `headline6`) to the new Material Design 3 system (`titleLarge`).
- **Stream/Future Mismatch:** Adjusted the types of variables holding the results of `getBanners` and `getCategories` to match the `Stream` return type of the service methods.
- **Widget Constructor Usage:** Corrected the usage of the `ProductDetailScreen` constructor to pass the required `productId`.
- **Provider Type Specification:** Specified the type for `ChangeNotifierProvider` in `main.dart`.
- **Null Safety for Image URLs:** Handled potential null `imageUrl` from the Product model by providing a placeholder image in `home_screen.dart` and `lib/screens/admin/product_list_screen.dart`.

## Plan for Current Request

Integrate the existing admin product list screen and implement navigation for edit, delete, and add product functionalities.

## Actions Taken for Current Request

1. Modified `lib/main.dart` to replace `AdminHomeScreenStub` with `lib/screens/admin/product_list_screen.dart` for users with admin claims.
2. Modified `lib/screens/admin/product_list_screen.dart` to:
    - Implement navigation to `EditProductScreen` when the edit icon is pressed.
    - Implement the logic to call `productService.deleteProduct` when the delete icon is pressed.
    - Implement navigation to `EditProductScreen` (without a product) when the floating action button is pressed to add a new product.
    - Handled potential null `imageUrl` from the Product model by providing a placeholder image.
    - Corrected interpolation syntax.
    - Changed the class name from `ProductListScreen` to `AdminProductListScreen` to avoid conflict with the user-facing product list screen.
    - Updated the `StreamBuilder` to use `productService.getAllProducts()`.
3. Updated `blueprint.md` to document the integration of the admin screens and the implemented functionalities.
