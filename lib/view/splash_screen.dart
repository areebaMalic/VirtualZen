import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
              height: 150.h,
            ),
            SizedBox(height: 20.h),
            Text(
              'Conquer Your Fear',
              style: TextStyle(
                color: Colors.black54,
                fontFamily: 'Esteban',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  void _checkLoginStatus(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final selectedPhobia = doc.data()?['selectedPhobia'];

      if (!context.mounted) return;
      if (selectedPhobia != null) {
        Navigator.pushReplacementNamed(context, RouteName.bottomBar);
      } else {
        Navigator.pushReplacementNamed(context, RouteName.welcome);
      }
    } else {
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, RouteName.welcome);
    }
  }

}
