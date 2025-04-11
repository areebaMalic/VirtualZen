import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/user_profile.dart';


class UserProvider with ChangeNotifier {
  UserProfile? _user;
  UserProfile? get user => _user;

  Future<void> fetchUserData() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        _user = UserProfile.fromMap(userDoc.data() as Map<String, dynamic>, uid);
      } else {
        _user = null; // Explicitly set null if no user data is found
      }

      notifyListeners(); // Notify UI that data has changed
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }


  void updateUser(UserProfile updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }
}
