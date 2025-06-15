import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../utils/components/filled_button_design.dart';
import '../utils/routes/route_name.dart';
import '../viewModel/profile_view_model.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Image.asset(
              'assets/images/welcome_pic.jpg', // Make sure to put your image in assets
              fit: BoxFit.cover, // Cover full width
            ),
          ),
          SizedBox(height: 80.h), // Space below the image
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.h,vertical: 6.w),
            child: Column(
              children: [
                Text(
                  "Welcome to VirtualZen",
                  style: TextStyle(
                      fontSize: 34.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Esteban',
                      color: profileViewModel.isDarkMode ? Colors.white: Colors.black
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15.h),
                Text(
                  "A serene space where you can relax and overcome your fears.",
                  style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.black54,
                      fontFamily: 'Esteban'
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const Spacer(), // Push button to the bottom
          Padding(
            padding:  EdgeInsets.all(20.r),
            child: SizedBox(
                width: double.infinity,
                height: 60.h,
                child: FilledButtonDesign(
                    title: "Start",
                    press: (){
                      Navigator.pushReplacementNamed(context, RouteName.signUp);
                    })
            ),
          ),
        ],
      ),
    );
  }
}