import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../model/friend_model.dart';
import '../model/user_model.dart';
import 'auth_view_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'friends_view_model.dart';

class ProfileViewModel extends ChangeNotifier {
  UserModel? currentUser;
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  List<FriendModel> friends = [];

  bool isDarkMode = false;
  bool hideOthersStatus = false;
  bool isLoadingProfile = true; // 🔥 NEW

  String? userName;
  String? pin;
  String? profileImageUrl;
  String? selectedPhobia;



  Future<void> loadUserProfile() async {
    isLoadingProfile = true; // 🔥 Start loading
    notifyListeners();

    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      isLoadingProfile = false;
      notifyListeners();
      return;
    }

    final docRef = _db.collection('users').doc(uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      isLoadingProfile = false;
      notifyListeners();
      return;
    }

    currentUser = UserModel.fromMap(doc.data()!, uid);

    if (!(currentUser?.hideOnlineStatus ?? false)) {
      await docRef.update({'isOnline': true});
    }

    hideOthersStatus = currentUser?.hideOnlineStatus ?? false;
    isDarkMode = currentUser?.isDarkMode ?? false;
    isLoadingProfile = false; // 🔥 Finished loading
    notifyListeners();
  }

  Future<void> setOffline() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _db.collection('users').doc(uid).update({
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> setHideOnlineStatus(BuildContext context, bool hide) async {
    if (hide) {
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (ctx) => AlertDialog(
          title: const Text("Confirm Action"),
          content: const Text(
            "You won’t be able to see others' online status and last seen if you hide yours. Do you want to continue?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Yes"),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _db.collection('users').doc(uid).update({'hideOnlineStatus': hide});
    currentUser = currentUser?.copyWith(hideOnlineStatus: hide);
    hideOthersStatus = hide;
    notifyListeners();
  }

  Future<void> updateName(String newName) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _db.collection('users').doc(uid).update({'name': newName});
    currentUser = currentUser?.copyWith(name: newName);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    isDarkMode = !isDarkMode;
    notifyListeners();

    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _db.collection('users').doc(uid).update({'isDarkMode': isDarkMode});
      currentUser = currentUser?.copyWith(isDarkMode: isDarkMode);
    }
  }

  Future<void> setDarkMode(bool value) async {
    isDarkMode = value;
    notifyListeners();

    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _db.collection('users').doc(uid).update({'isDarkMode': isDarkMode});
      currentUser = currentUser?.copyWith(isDarkMode: isDarkMode);
    }
  }

  Future<void> loadFriends() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final snapshot =
    await _db.collection('users').doc(uid).collection('friends').get();
    friends =
        snapshot.docs.map((doc) => FriendModel.fromDocument(doc)).toList();

    notifyListeners();
  }

  Future<void> removeFriend(String friendId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _db
        .collection('users')
        .doc(uid)
        .collection('friends')
        .doc(friendId)
        .delete();
    await _db
        .collection('users')
        .doc(friendId)
        .collection('friends')
        .doc(uid)
        .delete();
    await loadFriends();
  }

  Future<void> blockUser(String userIdToBlock) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _db
        .collection('users')
        .doc(uid)
        .collection('blocked')
        .doc(userIdToBlock)
        .set({});
  }

  Future<void> initializeUser() async {
    await loadUserProfile();
    // NotificationServices().requestNotificationPermission();
  }

  Future<void> logout(BuildContext context) async {

    await setOffline(); // mark user offline

    Provider.of<FriendsViewModel>(context, listen: false).reset();

    hideOthersStatus = false;
    userName = null;
    pin = null;
    profileImageUrl = null;
    friends = [];
    currentUser = null;
    notifyListeners();

    // Sign out the user using AuthViewModel
    await Provider.of<AuthViewModel>(context, listen: false).signOut(context);
  }

  void resetProfile() {
    currentUser = null;
    userName = null;
    pin = null;
    profileImageUrl = null;
    friends = [];
    hideOthersStatus = false;
    isLoadingProfile = false;
    notifyListeners();
  }


  Future<void> ensureUserProfileExists() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("No current user found!");
    }

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    int retries = 10; // retry for ~3 seconds (10 * 300ms)
    while (retries > 0) {
      final doc = await docRef.get();

      if (doc.exists) {
        print("User profile found.");
        return; // document is found, exit
      }

      // if not exists, wait for 300 ms and try again
      await Future.delayed(const Duration(milliseconds: 300));
      retries--;
    }

    throw Exception("Failed to find user profile after waiting.");
  }

  Future<void> tryLoadProfileWithRetry() async {
    isLoadingProfile = true;
    notifyListeners();

    int retries = 5; // Retry for about 5 * 500ms = 2.5 seconds
    while (retries > 0) {
      await loadUserProfile();

      if (currentUser != null) {
        isLoadingProfile = false;
        notifyListeners();
        return; // success
      }

      await Future.delayed(const Duration(milliseconds: 500));
      retries--;
    }

    isLoadingProfile = false;
    notifyListeners(); // after retries, even if failed
  }

  Future<void> updateProfileImage(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      if (pickedFile == null) return;

      final file = File(pickedFile.path);
      final cloudName = 'dnp4ncgro'; // Replace with your Cloudinary cloud name
      final uploadPreset =
          'profile'; // Replace with your unsigned upload preset

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'upload_preset': uploadPreset,
      });

      final response = await Dio().post(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
        data: formData,
      );

      final imageUrl = response.data['secure_url'];

      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      await _db.collection('users').doc(uid).update({'imageUrl': imageUrl});

      currentUser = currentUser?.copyWith(imageUrl: imageUrl);
      notifyListeners();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
    }
  }

}