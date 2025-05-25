import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/friend_model.dart';


class FriendsViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<String, StreamSubscription<DocumentSnapshot>> _presenceSubscriptions = {};
  final Map<String, StreamSubscription<QuerySnapshot>> _lastMessageSubscriptions = {};

  final List<FriendModel> _allFriends = [];
  List<FriendModel> _filteredFriends = [];

  List<FriendModel> get friends => _filteredFriends;
  int get friendCount => _filteredFriends.length;

  StreamSubscription? _friendsListSubscription;

  // 🚀 Public initializer to re-bind listeners after login
  void initialize() {
    listenToFriendList();
  }

  // 🔁 Reusable listener setup
  void listenToFriendList() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _friendsListSubscription?.cancel(); // cancel previous if any

    _friendsListSubscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('friends')
        .snapshots()
        .listen((snapshot) async {
      await _clearAllFriendData(); // Clear before populating new

      await Future.forEach(snapshot.docs, (QueryDocumentSnapshot doc) async {
        final friendId = doc.id;
        final userDoc = await _firestore.collection('users').doc(friendId).get();
        final userData = userDoc.data();

        final name = userData?['name'] ?? 'Unknown';
        final pin = userData?['pin'] ?? '';
        final imageUrl = userData?['imageUrl'] ?? '';

        final friend = FriendModel(
          id: friendId,
          name: name,
          pin: pin,
          imageUrl: imageUrl,
          isOnline: false,
          lastSeen: null,
          lastMessage: null,
        );

        _allFriends.add(friend);
        _filteredFriends = List.from(_allFriends);
        notifyListeners();

        // Presence listener
        _presenceSubscriptions[friendId] = _firestore
            .collection('users')
            .doc(friendId)
            .snapshots()
            .listen((userDoc) {
          final presenceData = userDoc.data();
          if (presenceData != null) {
            final index = _allFriends.indexWhere((f) => f.id == friendId);
            if (index != -1) {
              final current = _allFriends[index];
              _allFriends[index] = FriendModel(
                id: friendId,
                name: name,
                pin: pin,
                imageUrl: imageUrl,
                isOnline: presenceData['isOnline'] ?? false,
                lastSeen: (presenceData['lastSeen'] as Timestamp?)?.toDate(),
                lastMessage: current.lastMessage,
              );
              _filteredFriends = List.from(_allFriends);
              notifyListeners();
            }
          }
        });

        // Last message listener
        final chatId = uid.compareTo(friendId) < 0 ? '${uid}_$friendId' : '${friendId}_$uid';
        _lastMessageSubscriptions[friendId] = _firestore
            .collection('chatRooms')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((messageSnapshot) async {
          final messages = messageSnapshot.docs;

          // Count the number of unread messages for the friend
          final unreadMessages = messages.where((msg) {
            final seenBy = msg.data()['seenBy'] as List?; // Check for the field 'seenBy'
            return seenBy == null || !seenBy.contains(uid); // If 'seenBy' is null or doesn't contain the current user
          }).toList();

          final unreadCount = unreadMessages.length;

          // Get the last message and timestamp
          final lastMsg = messages.isNotEmpty ? messages.first.data()['text'] : null;
          final lastMsgTime = messages.isNotEmpty
              ? (messages.first.data()['timestamp'] as Timestamp?)?.toDate()
              : null;

          final index = _allFriends.indexWhere((f) => f.id == friendId);
          if (index != -1) {
            final current = _allFriends[index];
            _allFriends[index] = FriendModel(
              id: friendId,
              name: name,
              pin: pin,
              imageUrl: imageUrl,
              isOnline: current.isOnline,
              lastSeen: current.lastSeen,
              lastMessage: lastMsg,
              lastMessageTime: lastMsgTime,
              unreadCount: unreadCount, // Set the correct unread count here
            );

            // Update the filtered list
            _filteredFriends = List.from(_allFriends)
              ..sort((a, b) {
                final aTime = a.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
                final bTime = b.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
                return bTime.compareTo(aTime); // Sort in descending order (most recent first)
              });

            notifyListeners();
          }
        });

      });
    });
  }

  // 🧼 Clear subscriptions & data
  Future<void> _clearAllFriendData() async {
    for (var sub in _presenceSubscriptions.values) {
      await sub.cancel();
    }
    for (var sub in _lastMessageSubscriptions.values) {
      await sub.cancel();
    }
    _presenceSubscriptions.clear();
    _lastMessageSubscriptions.clear();
    _allFriends.clear();
    _filteredFriends.clear();
    notifyListeners();
  }

  // 🔓 Public method to clear on logout
  Future<void> clear() async {
    if (_friendsListSubscription != null) {
      await _friendsListSubscription?.cancel();
      _friendsListSubscription = null;
    }

    await _clearAllFriendData();
  }

  void reset() {
    _friendsListSubscription?.cancel();
    _friendsListSubscription = null;

    for (var sub in _presenceSubscriptions.values) {
      sub.cancel();
    }
    _presenceSubscriptions.clear();

    for (var sub in _lastMessageSubscriptions.values) {
      sub.cancel();
    }
    _lastMessageSubscriptions.clear();

    _allFriends.clear();
    _filteredFriends.clear();
    notifyListeners();
  }


  void searchFriends(String query) {
    if (query.isEmpty) {
      _filteredFriends = List.from(_allFriends);
    } else {
      _filteredFriends = _allFriends
          .where((f) =>
      f.name.toLowerCase().contains(query.toLowerCase()) ||
          f.pin.contains(query))
          .toList();
    }
    notifyListeners();
  }

  Future<void> removeFriend(String friendId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).collection('friends').doc(friendId).delete();
    await _firestore.collection('users').doc(friendId).collection('friends').doc(uid).delete();

    // Reload the friends list after removal
    listenToFriendList();
  }

  void updateUnreadCount(String friendId) {
    final index = _allFriends.indexWhere((f) => f.id == friendId);
    if (index != -1) {
      final currentFriend = _allFriends[index];
      _allFriends[index] = FriendModel(
        id: currentFriend.id,
        name: currentFriend.name,
        pin: currentFriend.pin,
        imageUrl: currentFriend.imageUrl,
        isOnline: currentFriend.isOnline,
        lastSeen: currentFriend.lastSeen,
        lastMessage: currentFriend.lastMessage,
        lastMessageTime: currentFriend.lastMessageTime,
        unreadCount: 0, // Reset the unread count to 0
      );
      _filteredFriends = List.from(_allFriends);
      notifyListeners();
    }
  }


  @override
  void dispose() {
    clear();
    super.dispose();
  }

}
