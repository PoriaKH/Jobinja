class Validators {
  static bool isEmailValid(String email) {
    return email.contains('@') && email.contains('.');
  }

  static bool isPasswordValid(String password) {
    return password.length >= 6;
  }
}