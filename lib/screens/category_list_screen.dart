import 'package:flutter/material.dart';
// You would likely fetch and display categories in a list here

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Categories'),
      ),
      body: const Center(
        child: Text('List of all categories will be here.'),
      ),
    );
  }
}
