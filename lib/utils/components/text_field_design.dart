import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constant.dart';


class TextFieldDesign extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final Function(FocusNode) focusFunction;
  final bool showIcon;
  final bool isobsecured;
  final VoidCallback? onIconTap;

  const TextFieldDesign({
    super.key,
    required this.focusFunction,
    required this.title ,
    required this.controller,
    required this.focusNode,
    this.showIcon = false,
    this.isobsecured =false,
    this.onIconTap,
    // required Null Function(dynamic value) onChanged,
  });


  @override
  Widget build(BuildContext context) {
    return TextField(
      onEditingComplete: ()=>focusFunction(focusNode!),
      focusNode: focusNode,
      controller: controller,
      obscureText: isobsecured,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: title,
        contentPadding:
        EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        labelStyle:  TextStyle(
            color: kLightTextColor,
            fontSize: 16.sp,
            fontFamily: 'Esteban',
            fontWeight: FontWeight.w400),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: kHighlightedTextColor,
            )),
        suffixIcon: showIcon ? IconButton(
          icon: Icon(
            isobsecured ? Icons.visibility: Icons.visibility_off ,
          ),
          onPressed: onIconTap, // This triggers the toggle
        ) : null,
      ),
      cursorColor: kHighlightedTextColor,
    );
  }
}