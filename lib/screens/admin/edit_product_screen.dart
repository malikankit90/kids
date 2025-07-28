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
  String? _selectedSubCategory;
  final List<File> _newImages = [];
  List<String> _existingImageUrls = [];
  final List<String> _imagesToDelete = [];
  List<String> _subcategories = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _stockController = TextEditingController(text: widget.product?.stock.toString() ?? '');
    _ageGroupController = TextEditingController(text: widget.product?.ageGroup ?? '');
    _genderController = TextEditingController(text: widget.product?.gender ?? '');
    _existingImageUrls = widget.product?.imageUrls ?? []; // Use imageUrls
    _selectedCategory = widget.product?.category;
    _selectedSubCategory = widget.product?.subcategory; // Use subcategory

     if (_selectedCategory != null) {
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
      _imagesToDelete.add(imageUrl);
     });
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isSaving = true;
    });

    try {
      final productService = Provider.of<ProductService>(context, listen: false);
      final Timestamp now = Timestamp.now();

      if (widget.product == null) {
        // Add new product
        final newProduct = Product(
          id: '',
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          category: _selectedCategory ?? '',
          subcategory: _selectedSubCategory ?? '',
          imageUrls: [], // Will be populated after upload
          stock: int.parse(_stockController.text.trim()),
          ageGroup: _ageGroupController.text.trim().isEmpty ? null : _ageGroupController.text.trim(),
          gender: _genderController.text.trim().isEmpty ? null : _genderController.text.trim(),
          createdAt: now,
          updatedAt: now,
        );
        await productService.addProduct(newProduct, _newImages);
      } else {
        // Update existing product
         final updatedProduct = Product(
          id: widget.product!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          category: _selectedCategory ?? '',
          subcategory: _selectedSubCategory ?? '',
          imageUrls: _existingImageUrls, // Pass the potentially modified list
          stock: int.parse(_stockController.text.trim()),
          ageGroup: _ageGroupController.text.trim().isEmpty ? null : _ageGroupController.text.trim(),
          gender: _genderController.text.trim().isEmpty ? null : _genderController.text.trim(),
          createdAt: widget.product!.createdAt,
          updatedAt: now,
        );
         await productService.updateProduct(
          updatedProduct,
          newImages: _newImages,
          imagesToDelete: _imagesToDelete,
        );
      }

      Navigator.pop(context); // Go back after saving
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save product: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }

    setState(() {
      _isSaving = false;
    });
  }

  Future<void> _fetchSubcategories(String categoryName) async {
     final categoryService = Provider.of<CategoryService>(context, listen: false);
     try {
       List<String> subcategories = await categoryService.getSubcategoriesForCategory(categoryName);
        setState(() {
         _subcategories = subcategories;
         // If the current product has a subcategory in the selected category, keep it
         if(widget.product != null && widget.product!.category == categoryName && subcategories.contains(widget.product!.subcategory)){
            _selectedSubCategory = widget.product!.subcategory; 
         } else {
           _selectedSubCategory = null;
         }
       });
     } catch (e) {
       print('Error fetching subcategories: $e');
        setState(() {
         _subcategories = [];
         _selectedSubCategory = null;
       });
     }
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
                validator: (val) {
                   if (val == null || val.isEmpty) {
                     return 'Please enter a price';
                   }
                   if (double.tryParse(val) == null) {
                     return 'Please enter a valid number';
                   }
                   return null;
                },
              ),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please enter stock quantity';
                  }
                  if (int.tryParse(val) == null) {
                     return 'Please enter a valid integer';
                   }
                  return null;
                },
              ),
              TextFormField(
                controller: _ageGroupController,
                decoration: const InputDecoration(labelText: 'Age Group (Optional)'),
              ),
              TextFormField(
                controller: _genderController,
                decoration: const InputDecoration(labelText: 'Gender (Optional)'),
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
                        _selectedSubCategory = null;
                        if (value != null) {
                           _fetchSubcategories(value);
                        } else {
                           _subcategories = [];
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
                decoration: const InputDecoration(labelText: 'Subcategory (Optional)'),
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
              if (_isSaving)
                const Center(child: CircularProgressIndicator())
              else
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
