import 'package:code/models/user.dart';
import 'package:code/presenters/profile_presenter.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  final ApiService apiService;

  const ProfileScreen({
    super.key,
    required this.apiService,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> implements ProfileView{
  late ProfilePresenter presenter;
  bool isLoading = false;
  String? errorMessage;
  User? user;

  // Define other variables
  //

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    presenter = ProfilePresenter(this, widget.apiService);
    presenter.loadProfile();
  }

  @override
  void hideLoading() {
    setState(() {
      isLoading = false;
    });
    // TODO: implement hideLoading
  }

  @override
  void showError(String message) {
    // TODO: implement showError
    setState(() {
      errorMessage = message;
      user = null;
    });
  }

  @override
  void showLoading() {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    // TODO: implement showLoading
  }

  @override
  void showProfile(User user) {
    // TODO: implement showProfile
    setState(() {
      this.user = user;
      errorMessage = null;
    });
  }

  void goBackToHome() {
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    Widget body;

    if (isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (errorMessage != null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            errorMessage!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else{
      body = ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          // final job = jobs[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListTile(
              subtitle: Text(
                '${user!.name}\n'
                    '${user!.email}\n',
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobinja Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: goBackToHome,
        ),
      ),
      body: Column(
        children: [
          Expanded(child: body),

          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: goBackToHome,
                child: const Text('Back To Home'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}