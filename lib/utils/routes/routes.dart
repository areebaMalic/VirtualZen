import 'package:flutter/material.dart';
import 'package:virtual_zen/utils/routes/route_name.dart';
import 'package:virtual_zen/view/add_friend_screen.dart';
import 'package:virtual_zen/view/community_screen.dart';
import 'package:virtual_zen/view/feed_screen.dart';
import 'package:virtual_zen/view/profile_screen.dart';
import '../../view/bottom_bar_navigation.dart';
import '../../view/chat_screen.dart';
import '../../view/email_send_screen.dart';
import '../../view/flying_hscreen.dart';
import '../../view/forget_password_screen.dart';
import '../../view/height_hscreen.dart';
import '../../view/login_page.dart';
import '../../view/phobia_list.dart';
import '../../view/reset_password_screen.dart';
import '../../view/sign_up_screen.dart';
import '../../view/spider_Hscreen.dart';
import '../../view/splash_screen.dart';
import '../../view/verification_screen.dart';
import '../../view/welcome_screen.dart';


class Routes{

  static Route<dynamic> generateRoute(RouteSettings setting){
    switch(setting.name){

      case RouteName.splash:
        return MaterialPageRoute(builder: (_) =>  const SplashScreen());

      case RouteName.bottomBar:
        return MaterialPageRoute(builder: (_) =>   BottomBarScreen());

      case RouteName.welcome:
        return MaterialPageRoute(builder: (_) => WelcomeScreen());

      case RouteName.login:
        return MaterialPageRoute(builder: (context) =>  LoginScreen());

      case RouteName.signUp:
        return MaterialPageRoute(builder: (context) => SignUpScreen());

      case RouteName.forgetPassword:
        return MaterialPageRoute(builder: (context) =>  ForgetPasswordScreen());

      case RouteName.resetPassword:
        return MaterialPageRoute(builder: (context) =>  ResetPasswordScreen());

      case RouteName.verification:
        return MaterialPageRoute(builder: (context) =>  const EmailVerificationScreen());

      case RouteName.emailOnWay:
        return MaterialPageRoute(builder: (context) =>  const EmailSendScreen());

      case RouteName.phobiaList:
        return MaterialPageRoute(builder: (context) =>   PhobiaListScreen());

      case RouteName.height:
        return MaterialPageRoute(builder: (context) =>   HeightsHomePage());

      case RouteName.flying:
        return MaterialPageRoute(builder: (context) =>   FlyingHomePage());

      case RouteName.spider:
        return MaterialPageRoute(builder: (context) =>   SpidersHomePage());

      case RouteName.profile:
        return MaterialPageRoute(builder: (context) =>   ProfileScreen());

      case RouteName.feed:
        return MaterialPageRoute(builder: (context) =>   Feed());

      case RouteName.community:
        return MaterialPageRoute(builder: (context) =>   CommunityScreen());

      case RouteName.chat:
        return MaterialPageRoute(builder: (context) =>   ChatScreen());

      case RouteName.addFriend:
        return MaterialPageRoute(builder: (context) =>   AddFriendScreen());


      default:
        return MaterialPageRoute(builder: (_){
          return const Scaffold(
            body: Center(
              child: Text('No Route found'),
            ),
          );
        });

    }
  }


}