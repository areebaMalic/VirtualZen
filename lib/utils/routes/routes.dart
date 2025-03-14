import 'package:flutter/material.dart';
import 'package:virtual_zen/utils/routes/route_name.dart';
import 'package:virtual_zen/view/phobia_list_screen.dart';
import 'package:virtual_zen/view/different_phobia_screen.dart';
import 'package:virtual_zen/view/verification_screen.dart';
import 'package:virtual_zen/view/welcome_screen.dart';

import '../../view/bottom_bar_navigation.dart';
import '../../view/email_send_screen.dart';
import '../../view/forget_password_screen.dart';
import '../../view/home_screen.dart';
import '../../view/login_page.dart';
import '../../view/reset_password_screen.dart';
import '../../view/sign_up_screen.dart';
import '../../view/splash_screen.dart';


class Routes{

  static Route<dynamic> generateRoute(RouteSettings setting){
    switch(setting.name){

      case RouteName.splash:
        return MaterialPageRoute(builder: (_) =>  const SplashScreen());

      case RouteName.setToGo:
      //   return MaterialPageRoute(builder: (_) =>  const SetTogoScreen());

      case RouteName.bottomBar:
        return MaterialPageRoute(builder: (_) =>   BottomBarScreen());

      case RouteName.welcome:
        return MaterialPageRoute(builder: (_) => WelcomeScreen());

      case RouteName.login:
        return MaterialPageRoute(builder: (context) =>  LoginScreen());

      case RouteName.pinSetup:
      //   return MaterialPageRoute(builder: (context) =>   const PinSetupScreen());

      case RouteName.accountSetup:
      //   return MaterialPageRoute(builder: (context) =>   const AccountSetupScreen());

      case RouteName.addNewAccount:
      //   return MaterialPageRoute(builder: (context) =>   AddNewAccountScreen());

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

      case RouteName.expense:
      //   return MaterialPageRoute(builder: (context) =>   ExpenseScreen());

      case RouteName.income:
      //   return MaterialPageRoute(builder: (context) =>   IncomeScreen());

      case RouteName.phobiaList:
        return MaterialPageRoute(builder: (context) =>   PhobiaListScreen());

      case RouteName.home:
        return MaterialPageRoute(builder: (context) =>   HomeScreen());

      case RouteName.height:
          return MaterialPageRoute(builder: (context) =>   HeightsHomePage());

      case RouteName.flying:
          return MaterialPageRoute(builder: (context) =>   FlyingHomePage());

      case RouteName.spider:
         return MaterialPageRoute(builder: (context) =>   SpidersHomePage());


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