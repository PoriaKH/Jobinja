import 'package:code/views/profile_screen.dart';
import 'package:flutter/material.dart';
import '../models/job.dart';
import '../presenters/job_presenter.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  final ApiService apiService;

  const HomeScreen({
    super.key,
    required this.apiService,
  });

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
    presenter = JobPresenter(this, widget.apiService);
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(apiService: presenter.apiService),
      ),
    );
  }

  void openJob(Job job){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected job URL: ${job.detailUrl}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
    } else {
      body = ListView.builder(
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListTile(
              title: Text(
                job.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${job.companyName}\n'
                    '${job.location}\n'
                    '${job.cooperationType}\n'
                    '${job.publishDate}',
              ),
              isThreeLine: true,
              onTap: () {
                openJob(job);
              },
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobinja Jobs'),
        actions: [
          IconButton(onPressed: openProfile, icon: const Icon (Icons.person)),
        ],
      ),
      body: body,
    );
  }
}