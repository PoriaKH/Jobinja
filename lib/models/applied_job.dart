class AppliedJob {
  final String shortId;
  final String title;
  final String companyName;
  final String companyEnglishName;
  final String status;
  final String machineStatus;
  final String createdAt;
  final String detailsLink;
  final String jobLink;
  final String? logoUrl;

  AppliedJob({
    required this.shortId,
    required this.title,
    required this.companyName,
    required this.companyEnglishName,
    required this.status,
    required this.machineStatus,
    required this.createdAt,
    required this.detailsLink,
    required this.jobLink,
    this.logoUrl,
  });
}