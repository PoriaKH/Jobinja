import 'package:flutter/material.dart';
import '../presenters/auth_presenter.dart';
import '../services/api_service.dart';
import '../utils/validators.dart';
import 'home_screen.dart';
import 'error_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> implements AuthView {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late AuthPresenter presenter;
  bool isLoading = false;
  late ApiService apiService;

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
        builder: (_) => HomeScreen(apiService: apiService),
      ),
    );
  }

  @override
  void onLoginError(String status) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ErrorScreen(errorStatus: status),
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
                : ElevatedButton(
              onPressed: handleLogin,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}