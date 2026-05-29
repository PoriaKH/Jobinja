import 'package:flutter/material.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key});

  void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coming Soon'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => goBack(context),
        ),
      ),
      body: const Center(
        child: Text(
          'Coming soon!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}