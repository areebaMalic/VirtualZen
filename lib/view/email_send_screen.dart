import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../utils/components/filled_button_design.dart';
import '../utils/routes/route_name.dart';
import '../viewModel/auth_view_model.dart';

class EmailSendScreen extends StatelessWidget {
  const EmailSendScreen({super.key});

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
                child: Text('Check your email ${authViewModel.email} and follow the instructions to reset your password',
                  textAlign: TextAlign.center,
                  style:  TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Esteban',
                  ),),
              );
            },),
          const Spacer(),
          FilledButtonDesign(
            title: 'Back to Login',
            press: (){
              Navigator.pushReplacementNamed(context, RouteName.resetPassword);
            },
          ),
          SizedBox(height: 20.h,),
        ],
      ),
    );
  }
}