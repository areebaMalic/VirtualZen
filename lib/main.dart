import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:virtual_zen/service/notification_services.dart';
import 'package:virtual_zen/utils/routes/route_name.dart';
import 'package:virtual_zen/utils/routes/routes.dart';
import 'package:virtual_zen/viewModel/add_friend_view_model.dart';
import 'package:virtual_zen/viewModel/auth_view_model.dart';
import 'package:virtual_zen/viewModel/chat_view_model.dart';
import 'package:virtual_zen/viewModel/forward_view_model.dart';
import 'package:virtual_zen/viewModel/friend_requests_view_model.dart';
import 'package:virtual_zen/viewModel/friends_view_model.dart';
import 'package:virtual_zen/viewModel/page_view_model.dart';
import 'package:virtual_zen/viewModel/phobia_view_model.dart';
import 'package:virtual_zen/utils/constant.dart';
import 'package:virtual_zen/viewModel/profile_view_model.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  NotificationServices notificationServices = NotificationServices();
  notificationServices.initializeLocalNotifications();

  notificationServices.firebaseInit();
  notificationServices.listenToTokenRefresh();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());

}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('💬 [Background] Message received: ${message.messageId}');
  print('📦 [Background] Data: ${message.data}');
  if (message.notification != null) {
    print('📝 [Background] Notification title: ${message.notification!.title}');
    print('📝 [Background] Notification body: ${message.notification!.body}');
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent
        )
    );

    return ScreenUtilInit(
      builder: (context, child) {
        return  MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => PageViewModel()),
              ChangeNotifierProvider(create: (_) => AuthViewModel()),
              ChangeNotifierProvider(create: (_) => PhobiaViewModel()),
              ChangeNotifierProvider(create: (_) => AddFriendViewModel()),
              ChangeNotifierProvider(create: (_) => ProfileViewModel()..initializeUser()),
              ChangeNotifierProvider(create: (_) => FriendRequestViewModel()),
              ChangeNotifierProvider(create: (_) => ChatViewModel()),
              ChangeNotifierProvider(create: (_) => ForwardViewModel()),
              ChangeNotifierProvider(create: (_) => FriendsViewModel()),
            ],
            child: Consumer(
              builder: (context, ProfileViewModel profileVM, child) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  navigatorKey: navigatorKey,
                  title: 'Flutter Demo',
                  theme:  Provider.of<ProfileViewModel>(context).isDarkMode ? darkTheme : lightTheme,
                  initialRoute: RouteName.splash,
                  onGenerateRoute: Routes.generateRoute,
                );
              },
            )
        );
      },
      designSize: const Size(375, 812),
    );
  }
}