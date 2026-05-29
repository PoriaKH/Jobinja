import 'package:code/views/profile_screen.dart';
import 'package:flutter/material.dart';
import '../models/job.dart';
import '../presenters/job_presenter.dart';
import '../services/api_service.dart';
import 'job_detail_screen.dart';

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

  void openJob(Job job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JobDetailScreen(
          detailUrl: job.detailUrl,
          apiService: presenter.apiService,
        ),
      ),
    );
  }

  Future<void> refreshJobs() async {
    await presenter.loadJobs();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (errorMessage != null) {
      body = RefreshIndicator(
        onRefresh: refreshJobs,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 70,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () async {
                      await refreshJobs();
                    },
                    child: const Text('Retry'),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Pull down to refresh',
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: refreshJobs,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
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
        ),
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