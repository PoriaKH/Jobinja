import '../models/job.dart';
import '../services/api_service.dart';

abstract class JobView {
  void showLoading();
  void hideLoading();
  void showJobs(List<Job> jobs);
  void showError(String message);
}

class JobPresenter {
  final JobView view;
  final ApiService apiService;

  JobPresenter(this.view, this.apiService);

  Future<void> loadJobs() async {
    view.showLoading();

    try {
      final jobs = await apiService.getJobs();
      view.hideLoading();
      showResult(jobs);
    } catch (e) {
      view.hideLoading();
      view.showError(e.toString());
    }
  }

  void showResult(List<Job> jobs) {
    if (jobs.isEmpty) {
      view.showError('No jobs found.');
    } else {
      view.showJobs(jobs);
    }
  }
}