import 'package:flutter/cupertino.dart';


class PageViewModel with ChangeNotifier{

  bool _isPasswordVisible  = true ;
  bool get isPasswordVisible => _isPasswordVisible;

  int _currentIndex = 1 ;
  int  get currentIndex => _currentIndex;


  void togglePasswordVisibility(){
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void setCurrentNavigationIndex(int index) {
    _currentIndex = index;
    notifyListeners(); // Notify listeners to rebuild the UI when index changes
  }

}