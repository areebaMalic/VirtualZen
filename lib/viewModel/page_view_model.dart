import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';


class PageViewModel with ChangeNotifier{

  bool _isPasswordVisible  = true ;
  bool get isPasswordVisible => _isPasswordVisible;

  int _currentIndex = 0 ;
  int  get currentIndex => _currentIndex;

  final PageController _pageController = PageController();
  PageController get pageController => _pageController;

  String? selectedPhobia;
  bool isLoading = true;

  Future<void> loadPhobia() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      selectedPhobia = doc.data()?['selectedPhobia'] as String?;
    }
    isLoading = false;
    notifyListeners();
  }


  Future<void> updatePhobia(String newPhobia) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'selectedPhobia': newPhobia,
      });
      selectedPhobia = newPhobia;
      notifyListeners();
    }
  }

  void resetPhobia() {
    selectedPhobia = null;
    _currentIndex = 0;
    _pageController.jumpToPage(0);
    notifyListeners();
  }


  void togglePasswordVisibility(){
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}