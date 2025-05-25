import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../main.dart';
import '../utils/routes/route_name.dart';
class NotificationServices {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static final NotificationServices _instance = NotificationServices._internal();
  factory NotificationServices() => _instance;
  NotificationServices._internal();


  void listenToTokenRefresh() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      if (kDebugMode) {
        print("🔁 Token refreshed: $newToken");
      }

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'fcmToken': newToken,
        });
      }
    });
  }

  void requestNotificationPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) print('User granted permission');
      getDeviceToken();
    } else {
      if (kDebugMode) print('User denied permission');
      AppSettings.openAppSettings();
    }
  }

  Future<void> getDeviceToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (kDebugMode && token != null) {
        if (kDebugMode) {
          print("Device Token: $token");
        }
      }

      // Save token to Firestore
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            'fcmToken': token,
          });
        }
      }
    } catch (e) {
      if (kDebugMode) print("Error getting device token: $e");
    }
  }


  void initializeLocalNotifications() {
    const androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidInitSettings);
    flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _handleNotificationTap, // <-- Tap handling
    );
  }

  void firebaseInit() {
    FirebaseMessaging.onMessage.listen((message) {
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNavigationFromMessage(message);
    });

    // When app is completely closed and opened by tapping notification
    _checkInitialMessage();
  }

  Future<void> _checkInitialMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNavigationFromMessage(initialMessage);
    }
  }

  Future<void> _showNotification(RemoteMessage message) async {
    final androidChannel = AndroidNotificationChannel(
      'friends_channel',
      'Friend Notifications',
      description: 'Channel for Friend App Notifications',
      importance: Importance.max,
    );

    final androidDetails = AndroidNotificationDetails(
      androidChannel.id,
      androidChannel.name,
      channelDescription: androidChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      message.notification.hashCode,
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? 'You have a new message.',
      notificationDetails,
      payload: _generatePayload(message), // <-- Pass payload for tapping
    );
  }

  // Create a string payload from message data
  String _generatePayload(RemoteMessage message) {
    final type = message.data['type'] ?? '';
    final chatRoomId = message.data['chatRoomId'] ?? '';
    final friendId = message.data['friendId'] ?? '';
    final friendName = message.data['friendName'] ?? '';

    // Check for any empty or null values and handle them
    if (chatRoomId.isEmpty || friendId.isEmpty || friendName.isEmpty) {
      return '';  // Return an empty string or a safe value
    }

    return '$type|$chatRoomId|$friendId|$friendName';
  }


  // When user taps on local notification
  void _handleNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      _navigateFromPayload(response.payload!);
    }
  }

  // When user taps on FCM notification (background or terminated state)
  void _handleNavigationFromMessage(RemoteMessage message) {
    final payload = _generatePayload(message);
    _navigateFromPayload(payload);
  }

  // Central navigation function
  void _navigateFromPayload(String payload) {
    final parts = payload.split('|');
    final type = parts[0];
    final chatRoomId = parts.length > 1 ? parts[1] : '';
    final friendId = parts.length > 2 ? parts[2] : '';
    final friendName = parts.length > 3 ? parts[3] : '';

    final nav = navigatorKey.currentState;

    switch (type) {
      case 'friend_request':
        nav?.pushNamed(RouteName.profile);
        break;

      case 'friend_approved':
        nav?.pushNamed(RouteName.community);
        break;

      case 'chat':
        if (chatRoomId.isNotEmpty && friendId.isNotEmpty) {
          nav?.pushNamed(
            RouteName.chat,
            arguments: {
              'chatRoomId': chatRoomId.isNotEmpty ? chatRoomId : null,
              'friendId': friendId.isNotEmpty ? friendId : null,
              'friendName': friendName.isNotEmpty ? friendName : null,
            },
          );
        }
        break;
    }

   /* if (type == 'friend_request') {
      navigatorKey.currentState?.pushNamed('/friendRequests');
    } else if (type == 'friend_approved') {
      navigatorKey.currentState?.pushNamed('/friends');
    } else if (type == 'chat' && chatRoomId.isNotEmpty && friendId.isNotEmpty) {
      // You can pass arguments if your ChatScreen accepts them
      navigatorKey.currentState?.pushNamed(
        '/chat',
        arguments: {
          'chatRoomId': chatRoomId.isNotEmpty ? chatRoomId : null,
          'friendId': friendId.isNotEmpty ? friendId : null,
          'friendName': friendName.isNotEmpty ? friendName : null,
        },
      );
    }*/
  }
}