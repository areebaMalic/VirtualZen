import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../utils/components/filled_button_design.dart';
import '../utils/routes/route_name.dart';
import '../viewModel/profile_view_model.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
    final isDark = profileViewModel.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Column(
        children: [
          SizedBox(height: 60.h),
          // 👓 Lottie Animation
          Lottie.asset(
            'assets/animations/vr_therapy.json',
            width: 300.w,
            height: 300.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 30.h),
          // ✨ Welcome Texts
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.w),
            child: Column(
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 600),
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Esteban',
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  child: const Text("Welcome to VirtualZen"),
                ),
                SizedBox(height: 12.h),
                Text(
                  "Experience immersive VR therapy to conquer fears and promote relaxation.",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontFamily: 'Esteban',
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const Spacer(),

          // 🌊 Glass-style Button Container
          Padding(
            padding: EdgeInsets.all(20.r),
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, RouteName.signUp);
              },
              child: Lottie.asset(
                'assets/animations/start_button.json',
                width: 300.w,
                height: 100.h,
                repeat: true,
                fit: BoxFit.contain,
              ),
            ),
          ),

        ],
      ),
    );
  }
}
