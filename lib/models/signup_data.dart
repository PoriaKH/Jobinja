class SignupPreparationResult {
  final bool success;
  final String status;
  final String csrfToken;
  final String signupUrl;

  SignupPreparationResult({
    required this.success,
    required this.status,
    required this.csrfToken,
    required this.signupUrl,
  });
}

class SignupResult {
  final bool success;
  final String status;

  SignupResult({
    required this.success,
    required this.status,
  });
}

class SignupFormData {
  final String email;
  final String fullName;
  final String password;
  final String confirmPassword;

  SignupFormData({
    required this.email,
    required this.fullName,
    required this.password,
    required this.confirmPassword,
  });
}