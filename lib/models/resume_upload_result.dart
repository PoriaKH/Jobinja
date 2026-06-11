class ResumeUploadResult {
  final bool success;
  final String status;
  final String? fileName;
  final String? uuid;
  final String? fileUrl;
  final int? score;

  ResumeUploadResult({
    required this.success,
    required this.status,
    this.fileName,
    this.uuid,
    this.fileUrl,
    this.score,
  });
}