import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/routes/route_name.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    _checkLoginStatus(context);
    return Scaffold(
      backgroundColor: Color(0xffCECECE),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo/logo_foreground.png',
              width: 150.w,
              height: 150.h,// Ensure this path is correct
            ),
            SizedBox(height: 20.h),
            Text('Conquer Your Fear',
              style: TextStyle(
                  color: Colors.black54,
                  fontFamily: 'Esteban',
                  fontSize: 24,
                  fontWeight: FontWeight.bold
              ),),
            SizedBox(height: 20.h),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
  void _checkLoginStatus(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? selectedPhobia = prefs.getString('selectedPhobia');

    await Future.delayed(Duration(seconds: 2));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return; // Ensure the context is still valid before navigation
      if (isLoggedIn && selectedPhobia != null) {
        Navigator.pushReplacementNamed(context, RouteName.bottomBar);
      } else {
        Navigator.pushReplacementNamed(context, RouteName.welcome);
      }
    });
  }

/* void _checkLoginStatus(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? selectedPhobia = prefs.getString('selectedPhobia');
    int? lastSelectedIndex = prefs.getInt('lastSelectedIndex');

    await Future.delayed(const Duration(seconds: 3));
    if (isLoggedIn && selectedPhobia != null) {
      Navigator.pushReplacementNamed(context, RouteName.bottomBar);
    } else {
      Navigator.pushReplacementNamed(context, RouteName.welcome);
    }
  }
}*/
}