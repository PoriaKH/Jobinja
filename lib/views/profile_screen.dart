import 'dart:io';

import 'package:code/models/user.dart';
import 'package:code/presenters/profile_presenter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/LogoutResult.dart';
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
  String? profileImagePath;

  final ImagePicker imagePicker = ImagePicker();

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

  @override
  void showProfileImage(String? imagePath) {
    setState(() {
      profileImagePath = imagePath;
    });
  }

  @override
  Future<String?> pickProfileImageFromGallery() async {
    final XFile? pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    return pickedImage?.path;
  }

  void goBackToHome() {
    Navigator.pop(context);
  }

  Future<void> changeProfilePicturePressed() async {
    await presenter.changeProfileImage();
  }

  Future<void> logoutPressed() async {
    LogoutResult result = await presenter.logout();

    if (result.success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong. Error: ${result.status}'),
        ),
      );
    }
  }

  ImageProvider? getProfileImageProvider() {
    if (profileImagePath == null || profileImagePath!.isEmpty) {
      return null;
    }

    final file = File(profileImagePath!);

    if (!file.existsSync()) {
      return null;
    }

    return FileImage(file);
  }

  Widget buildProfileAvatar() {
    final imageProvider = getProfileImageProvider();

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: imageProvider,
          child: imageProvider == null
              ? const Icon(
            Icons.person,
            size: 55,
          )
              : null,
        ),
        InkWell(
          onTap: changeProfilePicturePressed,
          child: CircleAvatar(
            radius: 17,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ],
    );
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
          buildProfileAvatar(),

          const SizedBox(height: 12),

          TextButton.icon(
            onPressed: changeProfilePicturePressed,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Choose Profile Picture'),
          ),

          const SizedBox(height: 12),

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