import '../models/company.dart';
import '../services/api_service.dart';

abstract class CompanyView {
  void showLoading();
  void hideLoading();
  void showCompany(Company company);
  void showError(String message);
}

class CompanyPresenter {
  final CompanyView view;
  final ApiService apiService;

  CompanyPresenter(this.view, this.apiService);

  Future<void> loadCompany(String companyUrl) async {
    view.showLoading();

    try {
      final company = await apiService.getCompany(companyUrl);
      view.hideLoading();
      view.showCompany(company);
    } catch (e) {
      view.hideLoading();
      view.showError(e.toString());
    }
  }
}