import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String username;
  final String email;
  final String profilePicture;
  final DateTime joinDate;
  final int followers;
  final int following;

  UserProfile({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    required this.profilePicture,
    required this.joinDate,
    required this.followers,
    required this.following,
  });

  factory UserProfile.fromMap(Map<String, dynamic> data, String uid) {
    return UserProfile(
      uid: uid,
      name: data['name'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      profilePicture: data['profilePicture'] ?? '',
      joinDate: (data['joinDate'] as Timestamp).toDate(),
      followers: data['followers'] ?? 0,
      following: data['following'] ?? 0,
    );
  }
}
