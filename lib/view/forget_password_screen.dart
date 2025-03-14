import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../utils/components/app_bar_text.dart';
import '../utils/components/filled_button_design.dart';
import '../utils/components/text_field_design.dart';
import '../utils/constant.dart';
import '../utils/routes/route_name.dart';
import '../viewModel/auth_view_model.dart';

class ForgetPasswordScreen extends StatelessWidget {

  final TextEditingController _emailController = TextEditingController();
  final FocusNode emailFocus = FocusNode();

  ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppBarText(text: 'Forget Password'),
        toolbarHeight: 100.h,
        centerTitle: true,
      ),
      body:  Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 60.w, horizontal: 16.h),
            child: Text('Don’t worry.\nEnter your email and we’ll send you a link to reset your password.' ,
              style: TextStyle(
                  fontSize: 24.sp,
                  fontFamily: 'Esteban',
                  fontWeight: FontWeight.w600
              ),),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextFieldDesign(
              focusFunction: (focusValue){
                fieldFocusChange(context, emailFocus, FocusNode());
              },
              title: 'Email',
              controller: _emailController,
              focusNode: emailFocus,
            ),
          ),
          SizedBox(height: 32.h,),
          Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              return  authViewModel.isLoading ? Center(
                child: SizedBox(
                  height: 40.h,
                  width: 40.w,
                  child: const CircularProgressIndicator(
                    color: kFilledButtonColor,
                    strokeWidth: 3,
                  ),
                ),
              ):
              FilledButtonDesign(
                  title: 'Continue',
                  press: (){
                    if(_emailController.text.isNotEmpty){
                      authViewModel.setEmail(_emailController.text.toString());
                      authViewModel.sendPasswordResetLink(_emailController.text.toString());
                      Navigator.pushNamed(context, RouteName.emailOnWay);
                    } else{
                      flushBarMessenger('Please enter your email', context);
                    }
                  }
              );
            },),
        ],
      ),
    );
  }
}