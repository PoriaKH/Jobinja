import '../models/job.dart';
import '../services/api_service.dart';

abstract class JobView {
  void showLoading();
  void hideLoading();
  void showJobs(List<Job> jobs, int page);
  void showError(String message);
}

class JobPresenter {
  final JobView view;
  final ApiService apiService;

  int currentPage = 1;

  JobPresenter(this.view, this.apiService);

  Future<void> loadJobs({int page = 1}) async {
    if (page < 1) return;

    view.showLoading();

    try {
      final jobs = await apiService.getJobs(page: page);

      view.hideLoading();

      if (jobs.isEmpty) {
        view.showError('No jobs found on this page.');
        return;
      }

      currentPage = page;
      view.showJobs(jobs, currentPage);
    } catch (e) {
      view.hideLoading();
      view.showError(e.toString());
    }
  }

  Future<void> refreshCurrentPage() async {
    await loadJobs(page: currentPage);
  }

  Future<void> nextPage() async {
    await loadJobs(page: currentPage + 1);
  }

  Future<void> previousPage() async {
    if (currentPage == 1) return;
    await loadJobs(page: currentPage - 1);
  }
}