class JobApplyResult {
  final bool success;
  final bool needsPhoneVerification;
  final String status;
  final String? phoneNumber;
  final String? formattedPhoneNumber;

  JobApplyResult({
    required this.success,
    required this.needsPhoneVerification,
    required this.status,
    this.phoneNumber,
    this.formattedPhoneNumber,
  });
}