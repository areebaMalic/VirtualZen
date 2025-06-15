import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../utils/components/account_login_signUp.dart';
import '../utils/components/app_bar_text.dart';
import '../utils/components/filled_button_design.dart';
import '../utils/components/term_condition_checkbox.dart';
import '../utils/components/text_field_design.dart';
import '../utils/constant.dart';
import '../utils/routes/route_name.dart';
import '../viewModel/auth_view_model.dart';
import '../viewModel/page_view_model.dart';
import '../viewModel/profile_view_model.dart';

class SignUpScreen extends StatelessWidget {


  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode nameFocus = FocusNode();

  SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final profileVM = Provider.of<ProfileViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: profileVM.isDarkMode ?  Colors.black : Colors.white,
        title: AppBarText(
            text: 'Sign Up',
            color: profileVM.isDarkMode ?  Colors.white : Colors.black ),
        toolbarHeight: 100.h,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:  EdgeInsets.symmetric(vertical: 5.h, horizontal: 16.w),
          child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFieldDesign(
                    onIconTap: () {},
                    focusFunction:(focusNode){
                      fieldFocusChange(context, nameFocus, emailFocus);
                    },
                    focusNode: nameFocus,
                    controller: _nameController,
                    title: 'Full Name',
                    showIcon: false,
                  ),
                  SizedBox(height: 24.h,),
                  TextFieldDesign(
                    onIconTap: () {},
                    focusFunction:  (focusNode){
                      fieldFocusChange(context, emailFocus, passwordFocus);
                    },
                    focusNode: emailFocus,
                    controller: _emailController,
                    title: 'Email',
                    showIcon: false,
                  ),
                  SizedBox(height: 24.h,),
                  Consumer<PageViewModel>(
                    builder: (context, pageViewModel, child) {
                      return  TextFieldDesign(
                        isObsecured: pageViewModel.isPasswordVisible,
                        onIconTap: () => pageViewModel.togglePasswordVisibility(),
                        focusFunction:   (focusNode){
                          fieldFocusChange(context, passwordFocus, FocusNode());
                        },
                        focusNode: passwordFocus,
                        controller: _passwordController,
                        title: 'Password',
                        showIcon: true,
                      );
                    },),
                  SizedBox(height: 25.h,),
                  const TermConditionCheckbox(
                    text: 'By signing up, you agree to the',
                    coloredText: ' Terms of Service and Privacy Policy',),
                  SizedBox(height: 27.h,),
                  Consumer<AuthViewModel>(
                    builder: (context, authViewModel, child){
                      return authViewModel.isLoading ?
                      Center(
                        child: SizedBox(
                          height: 40.h,
                          width: 40.w,
                          child: CircularProgressIndicator(
                            color: kFilledButtonColor,
                            strokeWidth: 3.w,
                          ),
                        ),
                      ): FilledButtonDesign(
                          title: 'Sign Up',
                          press:
                              () async {
                            String email = _emailController.text.trim();
                            String password = _passwordController.text.trim();
                            String name = _nameController.text.trim();

                            if(name.isEmpty && password.isEmpty && email.isEmpty){
                              return flushBarMessenger('Please Enter Required Fields', context);
                            }
                            else if(email.isEmpty){
                              return flushBarMessenger('Please Enter Email', context);
                            }
                            else if(password.isEmpty){
                              return flushBarMessenger('Please Enter Password', context);
                            }
                            else if(name.isEmpty){
                              return flushBarMessenger('Please Enter Name', context);
                            }
                            else if (password.length < 6) {
                              flushBarMessenger('Password must be at least 6 characters', context);
                            }
                            else if(!authViewModel.isChecked){
                              flushBarMessenger('Do agree with terms and Conditions', context);
                            }
                            else{

                              User? user = await authViewModel.signUpWithEmailPassword(email,password, name);
                              if(user!=null) {
                                Navigator.pushReplacementNamed(context, RouteName.verification);
                                flushBarMessenger(
                                  'A verification email has been sent. Please check your inbox.', context, showError: false,
                                );

                                _emailController.clear();
                                _nameController.clear();
                                _passwordController.clear();
                                authViewModel.toggleCheckBoxValue(false);

                              }
                              else{
                                flushBarMessenger('User not created ${authViewModel.errorMessage}', context);
                              }

                            }
                          }
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
                          String name = _nameController.text.trim();
                          User ? user = await authViewModel.signUpWithGoogle(name);
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
                  SizedBox(height: 19.h,),
                  AccountLoginSignUp(
                    title: 'Already have an account?',
                    subTitle: 'Login',
                    press: (){
                      Navigator.pushReplacementNamed(context, RouteName.login);
                    },
                  )
                ],
              )),
        ),
      ),
    );
  }
}

/*


// ✅ Modify Sign-Up Flow to Support Email Verification + Return from Gmail

// 🔧 During sign up (after creating user):
UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
await userCredential.user!.sendEmailVerification();

// ✅ Navigate to a new VerifyEmailScreen
Navigator.pushReplacement(
context,
MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
);

// ✅ Create VerifyEmailScreen

class VerifyEmailScreen extends StatefulWidget {
const VerifyEmailScreen({super.key});

@override
State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
bool isVerified = false;
bool isLoading = false;
late User user;

@override
void initState() {
super.initState();
user = FirebaseAuth.instance.currentUser!;
checkVerification();
}

Future<void> checkVerification() async {
await user.reload();
setState(() => user = FirebaseAuth.instance.currentUser!);
if (user.emailVerified) {
setState(() => isVerified = true);
Navigator.pushReplacementNamed(context, RouteName.phobiaListScreen);
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text("Verify Email")),
body: Padding(
padding: const EdgeInsets.all(20),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Text(
"We've sent a verification email to your Gmail.",
style: TextStyle(fontSize: 16, fontFamily: 'Esteban'),
textAlign: TextAlign.center,
),
const SizedBox(height: 20),
ElevatedButton(
onPressed: () async {
setState(() => isLoading = true);
await checkVerification();
setState(() => isLoading = false);
},
child: isLoading
? const CircularProgressIndicator(color: Colors.white)
    : const Text("I have verified", style: TextStyle(fontFamily: 'Esteban')),
)
],
),
),
);
}
}
*/
