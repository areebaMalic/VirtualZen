/*

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:virtual_zen/utils/routes/route_name.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});



  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, RouteName.welcome,);
    });

    return Scaffold(
      backgroundColor: Color(0xffD6D6D6),
      body: Center(
        child: Image.asset(
          'assets/logo/owl_logo.jpg',
          width: 200.w, // Ensure a fixed size
          height: 200.h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}


*/

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virtual_zen/utils/routes/route_name.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    _checkLoginStatus(context);
    return Scaffold(
      backgroundColor: Color(0xffD6D6D6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo/owl_logo.jpg', // Ensure this path is correct
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  void _checkLoginStatus(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? phobiaRoute = prefs.getString('selectedPhobia');

    await Future.delayed(const Duration(seconds: 3));
    if (isLoggedIn && phobiaRoute != null) {
      Navigator.pushReplacementNamed(context, RouteName.bottomBar);
    } else {
      Navigator.pushReplacementNamed(context, RouteName.welcome);
    }
  }
}