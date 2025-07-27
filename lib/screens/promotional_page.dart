import 'package:flutter/material.dart';

class PromotionalPage extends StatelessWidget {
  const PromotionalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Special Promotion'),
      ),
      body: const Center(
        child: Text('Details about the promotion will be here.'),
      ),
    );
  }
}
