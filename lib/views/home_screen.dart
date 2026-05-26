import 'package:flutter/material.dart';
import '../models/job.dart';
import '../presenters/job_presenter.dart';
import '../services/api_service.dart';
import '../widgets/job_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> implements JobView {
  late JobPresenter presenter;

  bool isLoading = false;
  String? errorMessage;
  List<Job> jobs = [];

  @override
  void initState() {
    super.initState();
    presenter = JobPresenter(this, ApiService());
    presenter.loadJobs();
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
  void showJobs(List<Job> jobs) {
    setState(() {
      this.jobs = jobs;
      errorMessage = null;
    });
  }

  @override
  void showError(String message) {
    setState(() {
      errorMessage = message;
      jobs = [];
    });
  }

  void openJobDetails(Job job) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected job: ${job.title}'),
      ),
    );
  }

  void openProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile page will be implemented later.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (errorMessage != null) {
      body = Center(child: Text(errorMessage!));
    } else {
      body = ListView.builder(
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          return JobCard(
            job: jobs[index],
            onTap: () => openJobDetails(jobs[index]),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobinja Jobs'),
        actions: [
          IconButton(
            onPressed: openProfile,
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: body,
    );
  }
}