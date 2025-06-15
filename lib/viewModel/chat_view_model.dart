import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:virtual_zen/viewModel/friends_view_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ChatViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _chatRoomId;
  String? get chatRoomId => _chatRoomId;

  final TextEditingController _inputController = TextEditingController();
  TextEditingController get inputController => _inputController;

  String? _friendId;
  String? get friendId => _friendId;


  final List<String> _selectedMessageIds = [];
  bool _isSelectionMode = false;

  List<String> get selectedMessageIds => _selectedMessageIds;
  bool get isSelectionMode => _isSelectionMode;

  String? _replyMessageId;
  String? _replyText;

  String? get replyMessageId => _replyMessageId;
  String? get replyText => _replyText;

  String? _friendName;
  String? get friendName => _friendName;

  String? _highlightedMessageId;
  String? get highlightedMessageId => _highlightedMessageId;

  String? _friendImageUrl;
  String? get friendImageUrl => _friendImageUrl;

  bool _shouldAutoScroll = true;
  bool get shouldAutoScroll => _shouldAutoScroll;

  final ScrollController scrollController = ScrollController();
  bool hasScrolledInitially = false;

  void setChatRoomId(String id) {
    _chatRoomId = id;
    notifyListeners();
  }

  void setFriendId(String id) {
    _friendId = id;
    notifyListeners();
  }

  Stream<QuerySnapshot> getMessages() {
    if (_chatRoomId == null) return const Stream.empty();
    return _firestore
        .collection('chatRooms')
        .doc(_chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Stream<DocumentSnapshot> getFriendStatusStream() {
    final members = _chatRoomId?.split('_') ?? [];
    final currentUserId = _auth.currentUser?.uid;

    // Early return if currentUserId is null or members is empty
    if (currentUserId == null || members.isEmpty) {
      return const Stream.empty();
    }

    final friendId = members.firstWhere((id) => id != currentUserId, orElse: () => '');

    if (friendId.isEmpty) {
      return const Stream.empty();
    }

    return _firestore.collection('users').doc(friendId).snapshots();
  }

  Future<void> sendMessage(String chatRoomId, String text, {bool isForwarded = false, String? replyToId}) async {
    if (text.isEmpty || _auth.currentUser == null) return;

    String? replyText;
    if (replyToId != null) {
      final replySnapshot = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(replyToId)
          .get();
      if (replySnapshot.exists) {
        replyText = replySnapshot['text'] ?? '';
      }
    }

    final message = {
      'senderId': _auth.currentUser!.uid,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isForwarded': isForwarded,
      'replyTo': replyToId,
      'replyText': replyText,
      'reactions': [],
    };

    await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(message);

    _replyMessageId = null;
    _replyText = null;
    notifyListeners();

    await sendPushNotification(chatRoomId, text, _auth.currentUser!.uid);
  }

  Future<void> sendPushNotification(String chatRoomId, String text, String senderId) async {
    try {
      final members = chatRoomId.split('_');
      final receiverId = members.firstWhere((id) => id != senderId);
      final receiverSnapshot = await _firestore.collection('users').doc(receiverId).get();
      final senderSnapshot = await _firestore.collection('users').doc(senderId).get();

      final token = receiverSnapshot.data()?['fcmToken'];
      final senderName = senderSnapshot.data()?['name'] ?? 'Someone';
      final receiverUsername = receiverSnapshot.data()?['username'] ?? receiverSnapshot.data()?['name'] ?? '';

      if (token == null) return;

      // Load service account credentials from file (ensure it's in assets and added in pubspec.yaml)
      final serviceAccount = ServiceAccountCredentials.fromJson(
        json.decode(await rootBundle.loadString('assets/firebase_service_account.json')),
      );

      // Set required scopes
      const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

      // Obtain authenticated HTTP client
      final client = await clientViaServiceAccount(serviceAccount, scopes);

      final fcmUrl = 'https://fcm.googleapis.com/v1/projects/virtualzenapp/messages:send';

      final message = {
        'message': {
          'token': token,
          'notification': {
            'title': ' ${receiverUsername.isNotEmpty ? ' @$receiverUsername' : ''}',
            'body': '$senderName: $text'
          },
          'data': {
            'type': 'chat',
            'chatRoomId': chatRoomId,
            'friendId': receiverId,
            'friendName': receiverSnapshot.data()?['name'] ?? '',
          },
        }
      };

      final response = await client.post(
        Uri.parse(fcmUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        debugPrint('FCM push sent');
      } else {
        debugPrint('FCM push error: ${response.statusCode} - ${response.body}');
      }

      client.close();
    } catch (e) {
      debugPrint('Push error: $e');
    }
  }

  Future<void> deleteMessage(String chatRoomId, String messageId) async {
    try {
      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }

  Future<void> deleteMessageForEveryone(String chatRoomId, String messageId) async {
    try {
      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({'deleted': true});
    } catch (e) {
      debugPrint('Delete for everyone error: $e');
    }
  }

  Future<void> deleteSelectedMessagesForEveryone(String chatRoomId) async {
    for (final id in _selectedMessageIds) {
      await deleteMessageForEveryone(chatRoomId, id);
    }
    clearSelection();
  }

  Future<void> forwardMessage({required String targetChatRoomId, required String originalText}) async {
    if (_auth.currentUser == null) return;
    await _firestore
        .collection('chatRooms')
        .doc(targetChatRoomId)
        .collection('messages')
        .add({
      'senderId': _auth.currentUser!.uid,
      'text': originalText,
      'timestamp': FieldValue.serverTimestamp(),
      'isForwarded': true,
    });
  }

  Future<void> forwardMultiple({required List<String> texts, required List<String> targetChatRoomIds}) async {
    for (final chatRoomId in targetChatRoomIds) {
      for (final text in texts) {
        await forwardMessage(targetChatRoomId: chatRoomId, originalText: text);
      }
    }
  }

  Future<void> unfriend(String currentUserId, String friendId, FriendsViewModel friendsVM) async {
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .doc(friendId)
        .delete();

    await _firestore
        .collection('users')
        .doc(friendId)
        .collection('friends')
        .doc(currentUserId)
        .delete();

    friendsVM.listenToFriendList();
    notifyListeners();
  }

  void toggleSelectionMode(String messageId) {
    _selectedMessageIds.contains(messageId)
        ? _selectedMessageIds.remove(messageId)
        : _selectedMessageIds.add(messageId);

    _isSelectionMode = _selectedMessageIds.isNotEmpty;
    notifyListeners();
  }

  void clearSelection() {
    _selectedMessageIds.clear();
    _isSelectionMode = false;
    notifyListeners();
  }

  bool isSelected(String messageId) => _selectedMessageIds.contains(messageId);

  Future<void> deleteSelectedMessages(String chatRoomId) async {
    for (final messageId in _selectedMessageIds) {
      await deleteMessage(chatRoomId, messageId);
    }
    clearSelection();
  }

  Future<void> copySelectedMessages(BuildContext context, List<DocumentSnapshot> allMessages) async {
    final selectedTexts = allMessages
        .where((msg) => _selectedMessageIds.contains(msg.id))
        .map((e) => e['text'] ?? '')
        .join('\n');

    Clipboard.setData(ClipboardData(text: selectedTexts));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
    clearSelection();
  }

  List<String> getSelectedTexts(List<DocumentSnapshot> allMessages) {
    return allMessages
        .where((msg) => _selectedMessageIds.contains(msg.id))
        .map((e) => (e['text'] ?? '').toString())
        .toList();
  }

  Future<void> toggleReaction(String chatRoomId, String messageId, String emoji) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final ref = _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId);

    try {
      final snapshot = await ref.get();
      if (!snapshot.exists) return;

      final data = snapshot.data();
      if (data == null) return;

      final List<dynamic> currentReactions = data['reactions'] ?? [];
      final reactions = List<Map<String, dynamic>>.from(currentReactions);

      final userReactionIndex = reactions.indexWhere((reaction) => reaction['userId'] == userId);

      if (userReactionIndex != -1) {
        if (reactions[userReactionIndex]['emoji'] == emoji) {
          // Same emoji tapped => remove reaction
          reactions.removeAt(userReactionIndex);
        } else {
          // Different emoji tapped => update reaction
          reactions[userReactionIndex]['emoji'] = emoji;
        }
      } else {
        // No reaction yet => add new
        reactions.add({'userId': userId, 'emoji': emoji});
      }

      await ref.update({'reactions': reactions});
    } catch (e) {
      debugPrint('Toggle reaction error: $e');
    }
  }

  void setReplyMessageId(String? messageId) {
    _replyMessageId = messageId;
    notifyListeners();
  }

  void setReplyText(String? text) {
    _replyText = text;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getMessageById(String chatRoomId, String messageId) async {
    try {
      final snapshot = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .get();

      return snapshot.exists ? snapshot.data() : null;
    } catch (e) {
      debugPrint('Get message error: $e');
      return null;
    }
  }

  void setFriendName(String name) {
    _friendName = name;
    notifyListeners();
  }

  void clearReply() {
    _replyMessageId = null;
    _replyText = null;
    notifyListeners();
  }

  void disposeController() {
    _inputController.dispose();
    super.dispose();
  }

  Future<bool> isSentByCurrentUser(String chatRoomId, String messageId) async {
    final userId = _auth.currentUser?.uid;
    final message = await getMessageById(chatRoomId, messageId);
    return message?['senderId'] == userId;
  }

  void setFriendImageUrl(String? url) {
    _friendImageUrl = url;
    notifyListeners();
  }

  void setHighlightedMessageId(String? id) {
    _highlightedMessageId = id;
    notifyListeners();
  }

  void clearHighlightedMessageId() {
    _highlightedMessageId = null;
    notifyListeners();
  }

  bool isHighlighted(String messageId) {
    return highlightedMessageId == messageId;
  }

  void setAutoScroll(bool value) {
    _shouldAutoScroll = value;
    notifyListeners();
  }

  void scrollToBottom({Duration delay = Duration.zero}) async {
    if (delay != Duration.zero) {
      await Future.delayed(delay);
    }
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void resetInitialScroll() {
    hasScrolledInitially = false;
  }

  Future<void> markMessagesAsRead(String chatRoomId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('seenBy', isNotEqualTo: uid)
        .get();

    for (var doc in snapshot.docs) {
      _firestore.collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(doc.id)
          .update({'seenBy': FieldValue.arrayUnion([uid])});
    }
    // Optionally, update unread count on Firestore here as well
    await _firestore.collection('users').doc(uid).collection('friends').doc(friendId).update({
      'unreadCount': 0,
    });
  }

  Future<String?> uploadToCloudinary(File imageFile) async {
    const cloudName = 'dnp4ncgro'; // from Cloudinary dashboard
    const uploadPreset = 'message image'; // from Cloudinary upload settings

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final data = json.decode(resStr);
      return data['secure_url']; // Cloudinary-hosted image URL
    } else {
      print('Cloudinary upload failed: \${response.statusCode}');
      return null;
    }
  }

  Future<void> sendImage(String chatRoomId, XFile imageFile, {String? replyToId}) async {
    try {
      final cloudinaryUrl = await uploadToCloudinary(File(imageFile.path));
      if (cloudinaryUrl == null) return;

      String? replyText;
      if (replyToId != null) {
        final replySnapshot = await _firestore
            .collection('chatRooms')
            .doc(chatRoomId)
            .collection('messages')
            .doc(replyToId)
            .get();
        if (replySnapshot.exists) {
          replyText = replySnapshot['text'] ?? '';
        }
      }

      final message = {
        'senderId': _auth.currentUser!.uid,
        'imageUrl': cloudinaryUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'replyTo': replyToId,
        'replyText': replyText,
        'reactions': [],
      };

      await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(message);

      _replyMessageId = null;
      _replyText = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Image send error: \$e');
    }
  }

}
