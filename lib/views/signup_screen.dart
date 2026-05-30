import 'package:flutter/material.dart';

import '../models/signup_data.dart';
import '../presenters/signup_presenter.dart';
import '../services/api_service.dart';
import 'signup_submit_webview_screen.dart';

class SignupScreen extends StatefulWidget {
  final ApiService apiService;

  const SignupScreen({
    super.key,
    required this.apiService,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> implements SignupView {
  final emailController = TextEditingController();
  final fullNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  late SignupPresenter presenter;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    presenter = SignupPresenter(this, widget.apiService);
  }

  void handleSignup() {
    presenter.startSignup(
      email: emailController.text.trim(),
      fullName: fullNameController.text.trim(),
      password: passwordController.text,
      confirmPassword: confirmPasswordController.text,
    );
  }

  @override
  void showLoading() {
    setState(() {
      isLoading = true;
    });
  }

  @override
  void hideLoading() {
    setState(() {
      isLoading = false;
    });
  }

  @override
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $message')),
    );
  }

  @override
  Future<void> openSignupSubmitPage(
      SignupPreparationResult preparation,
      SignupFormData formData,
      ) async {
    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SignupSubmitWebViewScreen(
          preparation: preparation,
          formData: formData,
        ),
      ),
    );

    if (success == true) {
      showSignupSuccess('Signup completed');
    } else {
      showError('Signup was cancelled or failed.');
    }
  }

  @override
  void showSignupSuccess(String status) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Signup request completed. Status: $status')),
    );

    Navigator.pop(context);
  }

  void goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobinja Sign Up'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: goBack,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: fullNameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: handleSignup,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}