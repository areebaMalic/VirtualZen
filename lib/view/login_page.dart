import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const AppBarText(text: 'Login',),
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
                    focusFunction: (focusNode){
                      fieldFocusChange(context, emailFocus, passwordFocus);
                    },
                    focusNode: emailFocus,
                    controller: _emailController,
                    title: 'Username',
                    showIcon: false,
                  ),
                  SizedBox(height: 24.h,),
                  Consumer<PageViewModel>(
                    builder: (context, pageViewModel, child){
                      return TextFieldDesign(
                        isobsecured: pageViewModel.isPasswordVisible,
                        onIconTap: () => pageViewModel.togglePasswordVisibility(),
                        focusFunction: (focusNode){
                          fieldFocusChange(context, passwordFocus, FocusNode());
                        },
                        focusNode: passwordFocus,
                        title: 'Password',
                        controller: _passwordController,
                        showIcon: true,
                      );
                    },),
                  SizedBox(height: 40.h,),
                  /*Consumer<AuthViewModel>(
                    builder: (context, authViewModel, child) {
                      return authViewModel.isLoading ?  Center(
                        child: SizedBox(
                          height: 40.h,
                          width: 40.w,
                          child: const CircularProgressIndicator(
                            color: kFilledButtonColor,
                            strokeWidth: 3,
                          ),
                        ),
                      ):   FilledButtonDesign(
                        title: 'Login',
                        press: () async{
                          String email = _emailController.text.trim();
                          String password = _passwordController.text.trim();
                          if(email.isEmpty && password.isEmpty){
                            return flushBarMessenger('Please Enter Required Fields', context );
                          }
                          else if(email.isEmpty){
                            return flushBarMessenger('Please enter email', context  );
                          }
                          else if(password.isEmpty){
                            return flushBarMessenger('Please enter password', context );
                          }
                          else{
                            User? user = await authViewModel.loginUserWithEmailPassword(email, password);
                            if(user != null){
                              bool isVerified = await authViewModel.checkEmailVerification(context);
                              if(!isVerified){
                                return flushBarMessenger(
                                    'Please verify your email before logging in', context,showError: true);
                              }


                           //   flushBarMessenger('User Logged In Successfully', context , showError: false );
                              _emailController.clear();
                              _passwordController.clear();

                              showToast("User Logged in successfully", kIncomeBackgroundColor);
                              Navigator.pushNamed(context, RouteName.phobiaList);

                            }else {
                              flushBarMessenger( authViewModel.errorMessage ?? 'Login Failed. Please check your credentials', context );
                            }
                          }
                        },
                      );
                    },
                  ),*/
                  Consumer<AuthViewModel>(
                    builder: (context, authViewModel, child) {
                      return FilledButtonDesign(
                        title: 'Login',
                        press: () async {
                          String email = _emailController.text.trim();
                          String password = _passwordController.text.trim();
                          User? user = await authViewModel.loginUserWithEmailPassword(email, password);

                          if (user != null) {
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('isLoggedIn', true);
                            bool isVerified = await authViewModel.checkEmailVerification(context);
                            if (isVerified) {
                              Navigator.pushNamed(context, RouteName.phobiaList);
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
                  SizedBox(height: 33.h,),
                  TextButton(
                    onPressed: (){
                      Navigator.pushNamed(context, RouteName.forgetPassword);
                    },
                    child: const Text('Forget Password?',
                        style: TextStyle(
                            color: kHighlightedTextColor,
                            fontFamily: 'Esteban'
                        )),),
                  AccountLoginSignUp(
                    title: "Don't have an account?",
                    subTitle: 'Sign Up',
                    press: (){
                      Navigator.pushNamed(context, RouteName.signUp);
                    },
                  )
                ],
              )),
        ),
      ),
    );
  }
}