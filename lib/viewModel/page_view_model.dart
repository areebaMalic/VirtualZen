import 'package:flutter/cupertino.dart';


class PageViewModel with ChangeNotifier{

  bool _isPasswordVisible  = true ;
  bool get isPasswordVisible => _isPasswordVisible;

  int _currentIndex = 0 ;
  int  get currentIndex => _currentIndex;

  PageController _pageController = PageController();
  PageController get pageController => _pageController;



  void togglePasswordVisibility(){
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void setCurrentNavigationIndex(int index) {
    _currentIndex = index;
    notifyListeners(); // Notify listeners to rebuild the UI when index changes
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }

  void onPageChanged(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}