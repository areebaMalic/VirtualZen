/*
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../utils/components/filled_button_design.dart';
import '../utils/constant.dart';
import '../utils/routes/route_name.dart';
import '../viewModel/auth_view_model.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 76.h,horizontal: 31.w),
            child: Image.asset('assets/images/email_on_the_way.png',height: 312.h,width: 312.w,),
          ),
          Text('Your email is on the way' ,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Esteban',
                fontWeight: FontWeight.w600,
                fontSize: 24.sp
            ),),
          Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              return Padding(
                padding:  EdgeInsets.symmetric(vertical: 24.h,horizontal: 24.w),
                child: Text('We have sent an email verification link to your email ${authViewModel.email}.You can check your email',
                  textAlign: TextAlign.center,
                  style:  TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Esteban',
                  ),),
              );
            },),
          const Spacer(),
          Consumer<AuthViewModel>(
            builder: (context, authViewModel ,child) {
              return FilledButtonDesign(
                title: 'Back to Login',
                press: () async {
                  bool isVerified = await authViewModel.checkEmailVerification(context);
                  if(isVerified){
                    Navigator.pushReplacementNamed(context, RouteName.login);
                  }else{
                    flushBarMessenger("Email not verified.Do check your inbox", context, showError: true);
                  }
                },
              );
            },
          ),
          SizedBox(height: 20.h,),
        ],
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../utils/components/filled_button_design.dart';
import '../utils/constant.dart';
import '../utils/routes/route_name.dart';
import '../viewModel/auth_view_model.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> with WidgetsBindingObserver {
  late AuthViewModel authViewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    authViewModel = Provider.of<AuthViewModel>(context, listen: false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Called when the app resumes from background
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      bool isVerified = await authViewModel.checkEmailVerification(context);
      if (isVerified) {
        Navigator.pushReplacementNamed(context, RouteName.phobiaList); // or bottomBar if appropriate
        flushBarMessenger("Email verified! Proceeding...", context, showError: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 76.h,horizontal: 31.w),
            child: Image.asset('assets/images/email_on_the_way.png',height: 312.h,width: 312.w,),
          ),
          Text('Your email is on the way' ,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Esteban',
                fontWeight: FontWeight.w600,
                fontSize: 24.sp
            ),),
          Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              return Padding(
                padding:  EdgeInsets.symmetric(vertical: 24.h,horizontal: 24.w),
                child: Text('We have sent an email verification link to your email ${authViewModel.email}.You can check your email',
                  textAlign: TextAlign.center,
                  style:  TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Esteban',
                  ),),
              );
            },),
          const Spacer(),
          Consumer<AuthViewModel>(
            builder: (context, authViewModel ,child) {
              return FilledButtonDesign(
                title: 'Back to Login',
                press: () async {
                  bool isVerified = await authViewModel.checkEmailVerification(context);
                  if(isVerified){
                    Navigator.pushReplacementNamed(context, RouteName.phobiaList);
                  } else {
                    flushBarMessenger("Email not verified. Please check again.", context);
                  }
                },
              );
            },
          ),
          SizedBox(height: 20.h,),
        ],
      ),
    );
  }
}
