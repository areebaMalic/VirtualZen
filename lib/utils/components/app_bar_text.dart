import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class AppBarText extends StatelessWidget {
  final String text;
  final Color color ;
  const AppBarText({
    super.key,
    this.color = Colors.black,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text ,
      style:  TextStyle(
          fontSize: 19.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'Esteban',
          color: color
      ),);
  }
}