import 'package:code/services/api_service.dart';

import '../models/LogoutResult.dart';
import '../models/ProfileResult.dart';
import '../models/user.dart';

abstract class ProfileView {
  void showLoading();
  void hideLoading();
  void showError(String message);
  void showProfile(User user);
  void showProfileImage(String? imagePath);
  Future<String?> pickProfileImageFromGallery();
}

class ProfilePresenter {
  final ProfileView view;
  final ApiService apiService;

  ProfilePresenter(this.view, this.apiService);

  Future<void> loadProfile() async {
    view.showLoading();

    try {
      final result = await apiService.getProfile();
      final imagePath = await apiService.getProfileImagePath();

      view.hideLoading();
      showResult(result);
      view.showProfileImage(imagePath);
    } catch (e) {
      view.hideLoading();
      view.showError(e.toString());
    }
  }

  void showResult(ProfileResult result) {
    if (result.success) {
      view.showProfile(result.user!);
    } else {
      view.showError(result.status);
    }
  }

  Future<void> changeProfileImage() async {
    final imagePath = await view.pickProfileImageFromGallery();

    if (imagePath == null || imagePath.isEmpty) {
      return;
    }

    await apiService.saveProfileImagePath(imagePath);
    view.showProfileImage(imagePath);
  }

  Future<LogoutResult> logout() async {
    view.showLoading();

    try {
      final result = await apiService.logoutRequest();
      view.hideLoading();
      return result;
    } catch (e) {
      view.hideLoading();
      return LogoutResult(success: false, status: "Logout failed!");
    }
  }
}