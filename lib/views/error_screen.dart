import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final String errorStatus;

  const ErrorScreen({
    super.key,
    required this.errorStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Something went wrong!\nError: $errorStatus',
          style: const TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}