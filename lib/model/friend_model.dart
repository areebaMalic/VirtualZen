import 'package:cloud_firestore/cloud_firestore.dart';

class FriendModel {
  final String id;
  final String name;
  final String pin;
  final bool isOnline;
  final DateTime? lastSeen;
  final String? lastMessage;
  String? lastMessageType;
  final String? imageUrl;
  final DateTime? lastMessageTime;
  final int unreadCount;
  bool isSelected;

  FriendModel({
    required this.id,
    required this.name,
    required this.pin,
    required this.isOnline,
    required this.lastSeen,
    this.lastMessage,
    this.lastMessageType,
    this.imageUrl,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isSelected = false,
  });

  FriendModel copyWith({bool? isSelected}) {
    return FriendModel(
      id: id,
      name: name,
      pin: pin,
      isOnline: isOnline,
      lastSeen: lastSeen,
      lastMessage: lastMessage,
      lastMessageType: lastMessageType,
      imageUrl: imageUrl,
      lastMessageTime: lastMessageTime,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  factory FriendModel.fromMap(String id, Map<String, dynamic> data) {
    return FriendModel(
      id: id,
      name: data['name'] ?? '',
      pin: data['pin'] ?? '',
      isOnline: data['isOnline'] ?? false,
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
      lastMessage: data['lastMessage'],
      lastMessageType: data['lastMessageType'],
      imageUrl: data['imageUrl'],
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
    );
  }

  factory FriendModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FriendModel.fromMap(doc.id, data);
  }
}