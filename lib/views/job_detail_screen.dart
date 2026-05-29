import 'package:flutter/material.dart';

import '../models/job_detail.dart';
import '../presenters/job_detail_presenter.dart';
import '../services/api_service.dart';
import 'company_screen.dart';

class JobDetailScreen extends StatefulWidget {
  final String detailUrl;
  final ApiService apiService;

  const JobDetailScreen({
    super.key,
    required this.detailUrl,
    required this.apiService,
  });

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen>
    implements JobDetailView {
  late JobDetailPresenter presenter;

  bool isLoading = false;
  String? errorMessage;
  JobDetail? jobDetail;

  @override
  void initState() {
    super.initState();
    presenter = JobDetailPresenter(this, widget.apiService);
    presenter.loadJobDetail(widget.detailUrl);
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
  void showJobDetail(JobDetail jobDetail) {
    setState(() {
      this.jobDetail = jobDetail;
      errorMessage = null;
    });
  }

  @override
  void showError(String message) {
    setState(() {
      errorMessage = message;
      jobDetail = null;
    });
  }

  void goBack() {
    Navigator.pop(context);
  }

  void openCompanyPage() {
    if (jobDetail == null || jobDetail!.companyUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Company page URL not found.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CompanyScreen(
          companyUrl: jobDetail!.companyUrl,
          city: jobDetail!.location,
          apiService: widget.apiService,
        ),
      ),
    );
  }

  Widget buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget buildSection(String title, String text) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(text),
          ],
        ),
      ),
    );
  }

  Widget buildBody() {
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
          ),
        ),
      );
    }

    if (jobDetail == null) {
      return const Center(
        child: Text('No job detail found.'),
      );
    }

    final job = jobDetail!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  buildInfoRow('Company', job.companyName),
                  buildInfoRow('Location', job.location),
                  buildInfoRow('Cooperation Type', job.cooperationType),
                  buildInfoRow('Seniority', job.seniority),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          buildSection('Job Description', job.description),
          buildSection('Required Skills', job.skills),
          buildSection('Working Conditions', job.conditions),
          buildSection('Benefits', job.benefits),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: openCompanyPage,
              icon: const Icon(Icons.business),
              label: const Text('View Company Page'),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: goBack,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
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
        title: const Text('Job Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: goBack,
        ),
      ),
      body: buildBody(),
    );
  }
}