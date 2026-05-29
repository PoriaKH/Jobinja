import 'package:code/models/user.dart';

class ProfileResult {
  final bool success;
  final String status;
  final User? user;

  ProfileResult({
    required this.success,
    required this.status,
    required this.user
  });
}