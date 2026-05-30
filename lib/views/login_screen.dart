import 'package:flutter/material.dart';

import '../presenters/auth_presenter.dart';
import '../services/api_service.dart';
import '../utils/validators.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> implements AuthView {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late AuthPresenter presenter;
  late ApiService apiService;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    apiService = ApiService();
    presenter = AuthPresenter(this, apiService);
  }

  void handleLogin() {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (!Validators.isEmailValid(email) ||
        !Validators.isPasswordValid(password)) {
      onLoginError('Invalid input');
      return;
    }

    presenter.login(email, password);
  }

  void openSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignupScreen(
          apiService: apiService,
        ),
      ),
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
  void onLoginSuccess() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          apiService: apiService,
        ),
      ),
    );
  }

  @override
  void onLoginError(String status) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Something went wrong. $status',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobinja Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),

            const SizedBox(height: 20),

            isLoading
                ? const CircularProgressIndicator()
                : Column(
              children: [
                ElevatedButton(
                  onPressed: handleLogin,
                  child: const Text('Login'),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: openSignup,
                  child: const Text('Create a new account'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}