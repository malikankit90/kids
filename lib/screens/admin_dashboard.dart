import 'package:flutter/material.dart';
import 'package:myapp/screens/admin/product_list_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Corrected class name to match the import
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminProductListScreen()));
              },
              child: const Text('Manage Products'),
            ),
            // Add other admin management options here
          ],
        ),
      ),
    );
  }
}
