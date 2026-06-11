import '../models/job_apply_result.dart';
import '../models/job_detail.dart';
import '../services/api_service.dart';

abstract class JobDetailView {
  void showLoading();
  void hideLoading();
  void showJobDetail(JobDetail jobDetail);
  void showError(String message);

  void showApplyLoading();
  void hideApplyLoading();
  void showApplyMessage(String message);
  Future<String?> askSmsCode(String phone);
}

class JobDetailPresenter {
  final JobDetailView view;
  final ApiService apiService;

  JobDetailPresenter(this.view, this.apiService);

  Future<void> loadJobDetail(String detailUrl) async {
    view.showLoading();

    try {
      final jobDetail = await apiService.getJobDetail(detailUrl);
      view.hideLoading();
      view.showJobDetail(jobDetail);
    } catch (e) {
      view.hideLoading();
      view.showError(e.toString());
    }
  }

  bool isValidMobile(String mobile) {
    final value = mobile.trim();
    return RegExp(r'^(09\d{9}|\+989\d{9})$').hasMatch(value);
  }

  Future<void> applyToJob(String detailUrl, String mobile) async {
    if (!isValidMobile(mobile)) {
      view.showApplyMessage('Invalid mobile number.');
      return;
    }

    view.showApplyLoading();

    final result = await apiService.applyToJob(
      jobDetailUrl: detailUrl,
      mobile: mobile.trim(),
    );

    view.hideApplyLoading();

    if (result.needsPhoneVerification) {
      final code = await view.askSmsCode(
        result.formattedPhoneNumber ?? result.phoneNumber ?? '',
      );

      if (code == null || code.trim().isEmpty) {
        view.showApplyMessage('Verification cancelled.');
        return;
      }

      view.showApplyLoading();

      final verified = await apiService.verifyJobApplySms(
        jobDetailUrl: detailUrl,
        mobile: mobile.trim(),
        smsCode: code.trim(),
      );

      view.hideApplyLoading();
      view.showApplyMessage(verified.status);
      return;
    }

    view.showApplyMessage(result.status);
  }
}