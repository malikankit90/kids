import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/product.dart';
import 'package:myapp/services/product_service.dart';
import 'package:myapp/services/category_service.dart'; // Import CategoryService
import 'package:myapp/models/category.dart'; // Import Category model
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProductScreen extends StatefulWidget {
  final Product? product; // Null for adding, provided for editing

  const EditProductScreen({super.key, this.product});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _ageGroupController;
  late TextEditingController _genderController;
  String? _selectedCategory;
  String? _selectedSubCategory; // You might need a separate list for subcategories
  List<File> _newImages = [];
  List<String> _existingImageUrls = [];
  List<String> _imagesToDelete = []; // Track images to delete
  List<String> _subcategories = []; // List to hold subcategories for the selected category


  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _stockController = TextEditingController(text: widget.product?.stock.toString() ?? '');
    _ageGroupController = TextEditingController(text: widget.product?.ageGroup ?? '');
    _genderController = TextEditingController(text: widget.product?.gender ?? '');
    _existingImageUrls = widget.product?.images ?? [];
    _selectedCategory = widget.product?.category;
    _selectedSubCategory = widget.product?.subCategory; // Initialize subcategory

     // Fetch subcategories if editing and category is already selected
    if (_selectedCategory != null && widget.product != null) {
      _fetchSubcategories(_selectedCategory!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _ageGroupController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _newImages.add(File(pickedFile.path));
      });
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  void _removeExistingImage(String imageUrl) {
     setState(() {
      _existingImageUrls.remove(imageUrl);
      _imagesToDelete.add(imageUrl); // Add image URL to the list of images to delete
     });
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final productService = Provider.of<ProductService>(context, listen: false);
      final Timestamp now = Timestamp.now();

      if (widget.product == null) {
        // Add new product
        final newProduct = Product(
          id: '', // Firestore will generate the ID
          name: _nameController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          category: _selectedCategory ?? '',
          subCategory: _selectedSubCategory ?? '',
          images: [], // Images will be added after upload
          stock: int.parse(_stockController.text),
          ageGroup: _ageGroupController.text,
          gender: _genderController.text,
          createdAt: now,
          updatedAt: now,
        );
        await productService.addProduct(newProduct, _newImages.map((file) => file.path).toList());
      } else {
        // Update existing product
         final updatedProduct = Product(
          id: widget.product!.id,
          name: _nameController.text,
          description: _descriptionController.text,
          price: double.parse(_priceController.text),
          category: _selectedCategory ?? '',
          subCategory: _selectedSubCategory ?? '',
          images: _existingImageUrls, // Start with existing images
          stock: int.parse(_stockController.text),
          ageGroup: _ageGroupController.text,
          gender: _genderController.text,
          createdAt: widget.product!.createdAt, // Keep original createdAt
          updatedAt: now,
        );
         await productService.updateProduct(
          updatedProduct,
          newImagePaths: _newImages.map((file) => file.path).toList(),
          imagesToDelete: _imagesToDelete, // Pass the list of images to delete
        );
      }

      Navigator.pop(context); // Go back after saving
    }
  }

  Future<void> _fetchSubcategories(String categoryName) async {
     final categoryService = Provider.of<CategoryService>(context, listen: false); // Access CategoryService
     List<String> subcategories = await categoryService.getSubcategoriesForCategory(categoryName);
     setState(() {
       _subcategories = subcategories;
       // If the current product has a subcategory, make sure it's still in the list
       if(widget.product != null && widget.product!.category == categoryName && _subcategories.contains(widget.product!.subCategory)){
          _selectedSubCategory = widget.product!.subCategory; // Keep the existing subcategory if it exists in the new list
       } else {
         _selectedSubCategory = null; // Reset subcategory if category changes or existing subcategory is not in the new list
       }
     });
  }


  @override
  Widget build(BuildContext context) {
     final categoryService = Provider.of<CategoryService>(context); // Access CategoryService

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (val) => val!.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (val) =>
                    val!.isEmpty ? 'Please enter a description' : null,
                maxLines: 3,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val!.isEmpty ? 'Please enter a price' : null,
              ),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val!.isEmpty ? 'Please enter stock quantity' : null,
              ),
              TextFormField(
                controller: _ageGroupController,
                decoration: const InputDecoration(labelText: 'Age Group'),
              ),
              TextFormField(
                controller: _genderController,
                decoration: const InputDecoration(labelText: 'Gender'),
              ),
              const SizedBox(height: 20),
              // Category Dropdown
               StreamBuilder<List<Category>>(
                stream: categoryService.getCategories(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error loading categories: ${snapshot.error}');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  final categories = snapshot.data ?? [];
                  return DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category.name,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                        _selectedSubCategory = null; // Reset subcategory when category changes
                        if (value != null) {
                           _fetchSubcategories(value); // Fetch subcategories for the new category
                        } else {
                           _subcategories = []; // Clear subcategories if no category is selected
                        }
                      });
                    },
                    validator: (val) =>
                        val == null ? 'Please select a category' : null,
                  );
                },
              ),
              const SizedBox(height: 20),
              // Subcategory Dropdown
               DropdownButtonFormField<String>(
                value: _selectedSubCategory,
                decoration: const InputDecoration(labelText: 'Subcategory'),
                 items: _subcategories.map((subCategory) {
                    return DropdownMenuItem(
                      value: subCategory,
                      child: Text(subCategory),
                    );
                  }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSubCategory = value;
                  });
                },
                // Validator is optional for subcategory, depending on your requirements
               ),
               const SizedBox(height: 20),
              // Image Upload Section
              const Text('Images:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ElevatedButton(onPressed: _pickImage, child: const Text('Pick Image')),
              const SizedBox(height: 10),
              // Display existing images
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _existingImageUrls.map((imageUrl) => Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _removeExistingImage(imageUrl),
                    ),
                  ],
                )).toList(),
              ),
               const SizedBox(height: 10),
              // Display new images to upload
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _newImages.asMap().entries.map((entry) {
                  int index = entry.key;
                  File imageFile = entry.value;
                   return Stack(
                  alignment: Alignment.topRight,
                  children: [
                     Image.file(imageFile, width: 100, height: 100, fit: BoxFit.cover),
                      IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _removeNewImage(index),
                    ),
                  ],
                );
                }).toList(),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProduct,
                child: Text(widget.product == null ? 'Add Product' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
