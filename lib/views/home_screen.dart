import 'package:code/views/profile_screen.dart';
import 'package:flutter/material.dart';

import '../models/job.dart';
import '../presenters/job_presenter.dart';
import '../services/api_service.dart';
import '../widgets/job_card.dart';
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
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    presenter = JobPresenter(this, widget.apiService);
    presenter.loadJobs(page: 1);
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
  void showJobs(List<Job> jobs, int page) {
    setState(() {
      this.jobs = jobs;
      currentPage = page;
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
    await presenter.refreshCurrentPage();
  }

  Widget buildPaginationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(
          top: BorderSide(color: Colors.black12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: currentPage == 1 || isLoading
                  ? null
                  : () {
                presenter.previousPage();
              },
              icon: const Icon(Icons.chevron_left),
              label: const Text('Previous'),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Page $currentPage',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isLoading
                  ? null
                  : () {
                presenter.nextPage();
              },
              icon: const Icon(Icons.chevron_right),
              label: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildErrorBody() {
    return RefreshIndicator(
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: refreshJobs,
                  child: const Text('Retry'),
                ),
                const SizedBox(height: 12),
                const Text('Pull down to refresh'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildJobsBody() {
    return RefreshIndicator(
      onRefresh: refreshJobs,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];

          return JobCard(
            job: job,
            onTap: () {
              openJob(job);
            },
          );
        },
      ),
    );
  }

  Widget buildBody() {
    if (isLoading && jobs.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return buildErrorBody();
    }

    return buildJobsBody();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jobinja Jobs - Page $currentPage'),
        actions: [
          IconButton(
            onPressed: openProfile,
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: Column(
        children: [
          if (isLoading && jobs.isNotEmpty)
            const LinearProgressIndicator(),

          Expanded(
            child: buildBody(),
          ),

          buildPaginationBar(),
        ],
      ),
    );
  }
}