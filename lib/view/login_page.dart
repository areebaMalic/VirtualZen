import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:virtual_zen/viewModel/profile_view_model.dart';
import '../utils/components/account_login_signUp.dart';
import '../utils/components/app_bar_text.dart';
import '../utils/components/filled_button_design.dart';
import '../utils/components/text_field_design.dart';
import '../utils/constant.dart';
import '../utils/routes/route_name.dart';
import '../viewModel/auth_view_model.dart';
import '../viewModel/page_view_model.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final profileVM = Provider.of<ProfileViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: profileVM.isDarkMode ?  Colors.black : Colors.white,
        title: AppBarText(
          text: 'Login' ,
          color: profileVM.isDarkMode ?  Colors.white : Colors.black ,
        ),
        centerTitle: true,
        toolbarHeight: 100.h,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 16.w),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFieldDesign(
                  onIconTap: () {},
                  focusFunction: (focusNode) {
                    fieldFocusChange(context, emailFocus, passwordFocus);
                  },
                  focusNode: emailFocus,
                  controller: _emailController,
                  title: 'Email',
                  showIcon: false,
                ),
                SizedBox(height: 24.h),
                Consumer<PageViewModel>(
                  builder: (context, pageViewModel, child) {
                    return TextFieldDesign(
                      isObsecured: pageViewModel.isPasswordVisible,
                      onIconTap: () => pageViewModel.togglePasswordVisibility(),
                      focusFunction: (focusNode) {
                        fieldFocusChange(context, passwordFocus, FocusNode());
                      },
                      focusNode: passwordFocus,
                      title: 'Password',
                      controller: _passwordController,
                      showIcon: true,
                    );
                  },
                ),
                SizedBox(height: 12.h,),
                Center(
                    child: Text('or with',
                      style: TextStyle(
                          color: kLightTextColor,
                          fontSize: 14.sp,
                          fontFamily: 'Esteban',
                          fontWeight: FontWeight.w700),)),
                SizedBox(height: 12.h,),
                Consumer<AuthViewModel>(
                  builder: (context, authViewModel, child) {
                    return InkWell(
                      onTap: () async {
                        User ? user = await authViewModel.signUpWithGoogle();
                        if (user != null) {
                          Navigator.pushNamed(context, RouteName.bottomBar);
                          flushBarMessenger("Login Successfully ", context , showError: false);
                        } else {
                          flushBarMessenger('Google Sign-In Failed', context);
                        }
                      },
                      child: SizedBox(
                        height: 56.h,
                        width: 343.w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/flat-color-icons_google.svg',
                              height: 32.h,
                              width: 32.w,
                            ),
                            SizedBox(width: 10.w,),
                            Text('Sign Up with Google',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontFamily: 'Esteban',
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },),
                //SizedBox(height: 19.h,),
                SizedBox(height: 40.h),
                Consumer<AuthViewModel>(
                  builder: (context, authViewModel, child) {
                    return FilledButtonDesign(
                      title: 'Login',
                      press: () async {
                        String email = _emailController.text.trim();
                        String password = _passwordController.text.trim();
                        User? user = await authViewModel.loginUserWithEmailPassword(email, password);

                        if (user != null) {
                          bool isVerified = await authViewModel.checkEmailVerification(context);

                          if (isVerified) {
                            Navigator.pushReplacementNamed(context, RouteName.bottomBar);
                          } else {
                            flushBarMessenger('Please verify your email before logging in', context);
                          }
                        } else {
                          flushBarMessenger(authViewModel.errorMessage ?? 'Login Failed', context);
                        }
                      },
                    );
                  },
                ),
                SizedBox(height: 33.h),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, RouteName.forgetPassword);
                  },
                  child: const Text(
                    'Forget Password?',
                    style: TextStyle(
                      color: kHighlightedTextColor,
                      fontFamily: 'Esteban',
                    ),
                  ),
                ),
                AccountLoginSignUp(
                  title: "Don't have an account?",
                  subTitle: 'Sign Up',
                  press: () {
                    Navigator.pushReplacementNamed(context, RouteName.signUp);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
