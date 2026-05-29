import 'job.dart';

class Company {
  final String name;
  final String logoUrl;
  final String description;
  final String industry;
  final String website;
  final List<Job> activeJobs;

  Company({
    required this.name,
    required this.logoUrl,
    required this.description,
    required this.industry,
    required this.website,
    required this.activeJobs,
  });
}