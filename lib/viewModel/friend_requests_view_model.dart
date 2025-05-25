import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../model/user_model.dart';
import '../service/notification_services.dart';

class FriendRequestViewModel extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _notificationService = NotificationServices();

  List<UserModel> requests = [];
  StreamSubscription? _requestListener;

  /// Start listening for incoming friend requests

  void listenForRequests() {
    _requestListener?.cancel();
    _requestListener = null;

    if (_requestListener != null) return;  /// already listening

    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _requestListener = _db
        .collection('users')
        .doc(uid)
        .collection('requests')
        .snapshots()
        .listen((snapshot) async {
      List<UserModel> updated = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        updated.add(UserModel(
          id: doc.id,
          name: data['name'] ?? 'Unknown',
          pin: data['pin'] ?? '',
        ));
      }

      /// Show notification for any new requests
      final newIds = updated.map((e) => e.id).toSet().difference(requests.map((e) => e.id).toSet());
      for (var id in newIds) {
        final newReq = updated.firstWhere((r) => r.id == id);
        await showRequestNotification(newReq.name);
      }

      requests = updated;
      notifyListeners();
    });
  }



  void stopListening() => _requestListener?.cancel();

  Future<void> approveRequest(UserModel sender) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final firestore = FirebaseFirestore.instance;
    final currentUserRef = firestore.collection('users').doc(currentUser.uid);
    final senderRef = firestore.collection('users').doc(sender.id);

    final batch = firestore.batch();

    try {
      print("Fetching current user's data...");
      final currentUserSnapshot = await currentUserRef.get();
      final currentUserData = currentUserSnapshot.data() as Map<String, dynamic>;
      print("Current user data: $currentUserData");

      print("Preparing friend data for current user...");
      final senderFriendData = {
        'id': sender.id,
        'name': sender.name,
        'pin': sender.pin,
        'isOnline': !(sender.hideOnlineStatus), // Assume "true" if not hidden
        'lastSeen': FieldValue.serverTimestamp(),
        'imageUrl': currentUserData['imageUrl'] ?? '',
        'lastMessage': null,
      };

      print("Preparing current user's friend data for sender...");
      final currentUserFriendData = {
        'id': currentUser.uid,
        'name': currentUserData['name'] ?? '',
        'pin': currentUserData['pin'] ?? '',
        'isOnline': !(currentUserData['hideOnlineStatus'] ?? false),
        'lastSeen': FieldValue.serverTimestamp(),
        'imageUrl': currentUserData['imageUrl'] ?? '',
        'lastMessage': null,
      };

      /// Add to each other's friends sub-collections
      print("Adding friend data to both users...");
      batch.set(currentUserRef.collection('friends').doc(sender.id), senderFriendData);
      batch.set(senderRef.collection('friends').doc(currentUser.uid), currentUserFriendData);

      /// Remove the request
      print("Removing friend request...");
      batch.delete(currentUserRef.collection('requests').doc(sender.id));

      print("Committing batch...");
      await batch.commit();

      /// Update local state
      requests.removeWhere((r) => r.id == sender.id);
      notifyListeners();

      print('Friend request approved and full friend data stored.');
    } catch (e) {
      print('Error approving request: $e');
    }
  }

  Future<void> rejectRequest(String senderId) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _db.collection('users').doc(uid).collection('requests').doc(senderId).delete();
    }
  }

  Future<void> showRequestNotification(String name) async {
    const androidDetails = AndroidNotificationDetails(
      'friend_req_channel',
      'Friend Request Alerts',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);
    await NotificationServices.flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'New Friend Request',
      '$name sent you a friend request!',
      details,
      payload: 'friend_request|||$name',  // You can define this better if needed
    );
  }

  Future<void> ensureListening() async {
    if (_requestListener != null) return; // Already listening
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _requestListener = _db.collection('users').doc(uid).collection('requests').snapshots().listen((snapshot) async {
      List<UserModel> loaded = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        loaded.add(UserModel(
          id: doc.id,
          name: data['name'] ?? '',
          pin: data['pin'] ?? '',
        ));
      }
      requests = loaded;
      notifyListeners();
    });
  }


  @override
  void dispose() {
    _requestListener?.cancel();
    super.dispose();
  }

  void clearRequests() {
    requests.clear();
    notifyListeners();
  }


}