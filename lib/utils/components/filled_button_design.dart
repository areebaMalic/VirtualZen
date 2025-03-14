import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constant.dart';

class FilledButtonDesign extends StatelessWidget {
  final String title;
  final VoidCallback press;
  const FilledButtonDesign({
    super.key,
    required this.title,
    required this.press
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: kFilledButtonColor,
            fixedSize:  Size(343.w, 56.h),
            padding:  EdgeInsets.all(8.0.r),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r)
            )
        ),
        onPressed: press,
        child: Text(
          title,
          style:  TextStyle(
              fontSize: 18.sp,
              fontFamily: 'Esteban',
              fontWeight: FontWeight.w600,
              color: kBackgroundThemeColor
          ),));
  }
}