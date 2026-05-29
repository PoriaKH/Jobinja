import '../models/job_detail.dart';
import '../services/api_service.dart';

abstract class JobDetailView {
  void showLoading();
  void hideLoading();
  void showJobDetail(JobDetail jobDetail);
  void showError(String message);
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
}