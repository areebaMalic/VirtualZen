import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constant.dart';

class AccountLoginSignUp extends StatelessWidget {
  final String  title;
  final String  subTitle;
  final VoidCallback press;

  const AccountLoginSignUp({
    required this.title,
    required this.subTitle,
    required this.press,
    super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              fontFamily: 'Esteban',
              fontSize: 15.sp,
              color: kLightTextColor
          ),
        ),
        TextButton(
            style: TextButton.styleFrom(
                padding: EdgeInsets.zero
            ),
            onPressed: press,
            child:  Text(
              subTitle,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15.sp,
                fontFamily: 'Esteban',
                color: kHighlightedTextColor,
               // decoration: TextDecoration.underline,
              ),))
      ],
    );
  }
}

