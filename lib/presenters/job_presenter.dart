import '../models/job.dart';
import '../models/job_filter.dart';
import '../services/api_service.dart';

abstract class JobView {
  void showLoading();
  void hideLoading();
  void showJobs(List<Job> jobs, int page);
  void showError(String message);
  void showFilterOptions(
      List<FilterOption> categories,
      List<FilterOption> provinces,
      );
  void showSkillSuggestions(List<JobSkill> skills);
}

class JobPresenter {
  final JobView view;
  final ApiService apiService;

  int currentPage = 1;
  JobFilter currentFilter = JobFilter();

  JobPresenter(this.view, this.apiService);

  Future<void> loadInitialData() async {
    await loadFilterOptions();
    await loadJobs(page: 1);
  }

  Future<void> loadFilterOptions() async {
    try {
      final categories = await apiService.getJobCategories();
      final provinces = await apiService.getProvinces();

      view.showFilterOptions(categories, provinces);
    } catch (e) {
      view.showError(e.toString());
    }
  }

  Future<void> searchSkills(String query) async {
    try {
      final skills = await apiService.searchJobSkills(query);
      view.showSkillSuggestions(skills);
    } catch (e) {
      view.showError(e.toString());
    }
  }

  Future<void> loadJobs({int page = 1}) async {
    if (page < 1) return;

    view.showLoading();

    try {
      final jobs = await apiService.getJobs(
        page: page,
        filter: currentFilter,
      );

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

  Future<void> applyFilters(JobFilter filter) async {
    currentFilter = filter;
    await loadJobs(page: 1);
  }

  Future<void> clearFilters() async {
    currentFilter = JobFilter();
    await loadJobs(page: 1);
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