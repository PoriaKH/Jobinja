import '../services/api_service.dart';

abstract class AuthView {
  void showLoading();
  void hideLoading();
  void onLoginSuccess();
  void onLoginError(String status);
}

class AuthPresenter {
  final AuthView view;
  final ApiService apiService;

  AuthPresenter(this.view, this.apiService);

  Future<void> login(String email, String password) async {
    view.showLoading();

    final result = await apiService.login(email, password);

    view.hideLoading();

    if (result.success) {
      view.onLoginSuccess();
    } else {
      view.onLoginError(result.status);
    }
  }
}