import '../models/signup_data.dart';
import '../services/api_service.dart';

abstract class SignupView {
  void showLoading();
  void hideLoading();
  void showError(String message);
  void openSignupSubmitPage(
      SignupPreparationResult preparation,
      SignupFormData formData,
      );
  void showSignupSuccess(String status);
}

class SignupPresenter {
  final SignupView view;
  final ApiService apiService;

  SignupPresenter(this.view, this.apiService);

  Future<void> startSignup({
    required String email,
    required String fullName,
    required String password,
    required String confirmPassword,
  }) async {
    if (email.isEmpty ||
        fullName.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      view.showError('Please fill all fields.');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      view.showError('Invalid email.');
      return;
    }

    if (password.length < 6) {
      view.showError('Password must be at least 6 characters.');
      return;
    }

    if (password != confirmPassword) {
      view.showError('Passwords do not match.');
      return;
    }

    view.showLoading();

    final preparation = await apiService.prepareSignup();

    view.hideLoading();

    if (!preparation.success) {
      view.showError(preparation.status);
      return;
    }

    final formData = SignupFormData(
      email: email,
      fullName: fullName,
      password: password,
      confirmPassword: confirmPassword,
    );

    view.openSignupSubmitPage(preparation, formData);
  }
}