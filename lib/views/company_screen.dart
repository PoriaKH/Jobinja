import 'package:flutter/material.dart';

import '../models/company.dart';
import '../models/job.dart';
import '../presenters/company_presenter.dart';
import '../services/api_service.dart';
import 'coming_soon_screen.dart';

class CompanyScreen extends StatefulWidget {
  final String companyUrl;
  final String city;
  final ApiService apiService;

  const CompanyScreen({
    super.key,
    required this.companyUrl,
    required this.city,
    required this.apiService,
  });

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> implements CompanyView {
  late CompanyPresenter presenter;

  bool isLoading = false;
  String? errorMessage;
  Company? company;

  @override
  void initState() {
    super.initState();
    presenter = CompanyPresenter(this, widget.apiService);
    presenter.loadCompany(widget.companyUrl);
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
  void showCompany(Company company) {
    setState(() {
      this.company = company;
      errorMessage = null;
    });
  }

  @override
  void showError(String message) {
    setState(() {
      errorMessage = message;
      company = null;
    });
  }

  void goBack() {
    Navigator.pop(context);
  }

  void openComingSoon(Job job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ComingSoonScreen(),
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

    if (company == null) {
      return const Center(
        child: Text('No company information found.'),
      );
    }

    final c = company!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (c.logoUrl.isNotEmpty)
            CircleAvatar(
              radius: 45,
              backgroundImage: NetworkImage(c.logoUrl),
            )
          else
            const CircleAvatar(
              radius: 45,
              child: Icon(Icons.business, size: 45),
            ),

          const SizedBox(height: 16),

          Text(
            c.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: const Text('Industry'),
                  subtitle: Text(c.industry.isEmpty ? 'Not found' : c.industry),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: const Text('City'),
                  subtitle: Text(
                    widget.city.isEmpty ? 'Not available' : widget.city,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Website'),
                  subtitle: Text(c.website.isEmpty ? 'Not found' : c.website),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About Company',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(c.description.isEmpty ? 'No description found.' : c.description),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Active Jobs (${c.activeJobs.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 8),

          for (final job in c.activeJobs)
            Card(
              child: ListTile(
                title: Text(job.title),
                subtitle: Text(
                  '${job.companyName}\n${job.location}\n${job.cooperationType}',
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openComingSoon(job),
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
        title: const Text('Company Page'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: goBack,
        ),
      ),
      body: buildBody(),
    );
  }
}