import 'package:code/services/api_service.dart';

import '../models/user.dart';

abstract class ProfileView{
  void showLoading();
  void hideLoading();
  void showError(String message);
  void showProfile(User user);
}

class ProfilePresenter {
  final ProfileView view;
  final ApiService apiService;

  ProfilePresenter(this.view, this.apiService);

  Future<void> loadProfile() async{
    view.showLoading();
    //TODO...
    try{
      final result = await apiService.getProfile();
      view.hideLoading();
      showResult(result);
    } catch (e){
      view.hideLoading();
      view.showError(e.toString());
    }
  }
  void showResult(ProfileResult result){
    if(result.success){
      view.showProfile(result.user!);
    }
    else{
      view.showError(result.status);
    }
  }
  Future<LogoutResult> logout() async{
  //   TODO...
    view.showLoading();
    try{
      final result = await apiService.logoutRequest();
      view.hideLoading();
      return result;
    }catch(e){
      view.hideLoading();
      return LogoutResult(success: false, status: "Logout failed!");
    }


  }
}