import 'package:flutter/material.dart';

class CompanyScreen extends StatelessWidget {
  const CompanyScreen({super.key});

  void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Page'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => goBack(context),
        ),
      ),
      body: const Center(
        child: Text(
          'We are implementing it.',
          style: TextStyle(fontSize: 22),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}