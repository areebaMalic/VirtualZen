import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../utils/components/app_bar_text.dart';
import '../utils/components/filled_button_design.dart';
import '../utils/components/text_field_design.dart';
import '../utils/constant.dart';
import '../utils/routes/route_name.dart';
import '../viewModel/auth_view_model.dart';

class ResetPasswordScreen extends StatelessWidget {
  ResetPasswordScreen({super.key});

  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _reNewPasswordController = TextEditingController();

  final FocusNode newPasswordFocus = FocusNode();
  final FocusNode retypePasswordFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppBarText(text: 'Reset Password'),
        toolbarHeight: 100.h,
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 56.h),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextFieldDesign(
              title: 'New Password',
              controller: _newPasswordController,
              focusNode: newPasswordFocus,
              focusFunction: (focusValue) {
                fieldFocusChange(context, newPasswordFocus, retypePasswordFocus);
              },
            ),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextFieldDesign(
              title: 'Retype New Password',
              controller: _reNewPasswordController,
              focusNode: retypePasswordFocus,
              focusFunction: (focusValue) {
                fieldFocusChange(context, retypePasswordFocus, FocusNode());
              },
            ),
          ),
          SizedBox(height: 32.h),
          Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              if (authViewModel.errorMessage != null) {
                flushBarMessenger(authViewModel.errorMessage!, context);
              }
              return authViewModel.isLoading
                  ? Center(
                child: SizedBox(
                  height: 40.h,
                  width: 40.w,
                  child: const CircularProgressIndicator(
                    color: kFilledButtonColor,
                    strokeWidth: 3,
                  ),
                ),
              )
                  : FilledButtonDesign(
                title: 'Continue',
                press: () async {
                  await authViewModel.checkResetPassword(
                    _newPasswordController.text.trim(),
                    _reNewPasswordController.text.trim(),
                  );
                  if (authViewModel.errorMessage == 'Password updated successfully') {
                    Navigator.pushReplacementNamed(context, RouteName.login);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}