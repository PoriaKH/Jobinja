import 'package:code/services/api_service.dart';

import '../models/LogoutResult.dart';
import '../models/ProfileResult.dart';
import '../models/user.dart';
import '../models/resume_upload_result.dart';
import '../models/applied_job.dart';

abstract class ProfileView {
  void showLoading();
  void hideLoading();
  void showError(String message);
  void showProfile(User user);
  void showProfileImage(String? imagePath);
  Future<String?> pickProfileImageFromGallery();
  Future<String?> pickResumeFile();
  void showResumeUploadResult(ResumeUploadResult result);
  void showAppliedJobs(List<AppliedJob> jobs);
  void showAppliedJobsError(String message);
  Future<bool> confirmDeleteResume();
  void showResumeDeleteResult(ResumeUploadResult result);
  void showResumeStatus(bool isUploaded);
}

class ProfilePresenter {
  final ProfileView view;
  final ApiService apiService;

  ProfilePresenter(this.view, this.apiService);

  Future<void> loadProfile() async {
    view.showLoading();
    await loadResumeStatus();

    try {
      final result = await apiService.getProfile();
      final imagePath = await apiService.getProfileImagePath();

      view.hideLoading();
      showResult(result);
      view.showProfileImage(imagePath);
      await loadAppliedJobs();
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

  Future<void> uploadResume() async {
    final filePath = await view.pickResumeFile();

    if (filePath == null || filePath.isEmpty) {
      return;
    }

    view.showLoading();

    final result = await apiService.uploadResume(filePath);

    view.hideLoading();
    view.showResumeUploadResult(result);
    await loadResumeStatus();
  }

  Future<void> loadAppliedJobs() async {
    try {
      final jobs = await apiService.getAppliedJobs();
      view.showAppliedJobs(jobs);
    } catch (e) {
      view.showAppliedJobsError(e.toString());
    }
  }

  Future<void> deleteResume() async {
    final confirmed = await view.confirmDeleteResume();

    if (!confirmed) {
      return;
    }

    view.showLoading();

    final result = await apiService.deleteResume();

    view.hideLoading();
    view.showResumeDeleteResult(result);
    await loadResumeStatus();
  }

  Future<void> loadResumeStatus() async {
    try {
      final uploaded = await apiService.isResumeUploaded();
      view.showResumeStatus(uploaded);
    } catch (e) {
      view.showResumeStatus(false);
    }
  }
}