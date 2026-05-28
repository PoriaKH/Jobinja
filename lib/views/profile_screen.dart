import 'package:code/models/user.dart';
import 'package:code/presenters/profile_presenter.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ApiService apiService;

  const ProfileScreen({
    super.key,
    required this.apiService,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> implements ProfileView {
  late ProfilePresenter presenter;
  bool isLoading = false;
  String? errorMessage;
  User? user;

  @override
  void initState() {
    super.initState();
    presenter = ProfilePresenter(this, widget.apiService);
    presenter.loadProfile();
  }

  @override
  void showLoading() {
    setState(() {
      isLoading = true;
      errorMessage = null;
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
    setState(() {
      errorMessage = message;
      user = null;
    });
  }

  @override
  void showProfile(User user) {
    setState(() {
      this.user = user;
      errorMessage = null;
    });
  }

  void goBackToHome() {
    Navigator.pop(context);
  }

  Future<void> logoutPressed() async {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(
    //     content: Text('We are implementing logout feature.'),
    //   ),
    // );
    LogoutResult result = await presenter.logout();

    if (result.success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(),
        ),
      );
    }
    else{
      String message = result.status;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong. Error: $message'),
        ),
      );
    }
  }

  Widget buildProfileBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    if (user == null) {
      return const Center(
        child: Text('No profile information found.'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 45,
            child: Icon(
              Icons.person,
              size: 55,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            user!.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 6),

          Text(
            user!.email,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 28),

          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Full Name'),
                  subtitle: Text(user!.name),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email Address'),
                  subtitle: Text(user!.email),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: goBackToHome,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back To Home'),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: logoutPressed,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobinja Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: goBackToHome,
        ),
      ),
      body: buildProfileBody(),
    );
  }
}