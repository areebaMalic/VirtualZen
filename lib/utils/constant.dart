import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';


const kBackgroundThemeColor = Color(0xFFffffff);
const kLightTextColor = Color(0xFF91919F);
const kFilledButtonColor = Color(0xff3094E8);
const kHighlightedTextColor = Color(0xff4F7596);
const kUnfilledButtonColor = Color(0xffEEE5FF);
const kRedBackgroundColor = Color(0xffFD3C4A);
const kGreenBackgroundColor = Color(0xff00A86B);
const kTransactionBackgroundColor = Color(0xff0077FF);

void fieldFocusChange(BuildContext context , FocusNode current , FocusNode nextFocus){
  current.unfocus();
  FocusScope.of(context).requestFocus(nextFocus);
}


void flushBarMessenger(String message , BuildContext context , {bool showError = true}){
  showFlushbar(
      context: context,
      flushbar: Flushbar(
        padding:  EdgeInsets.all(16.0.r),
        margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
        message: message,
        backgroundColor: showError ? kRedBackgroundColor : kGreenBackgroundColor,
        icon: const Icon(Icons.error_outline , color: kBackgroundThemeColor,),
        borderRadius: BorderRadius.circular(13.r),
        duration: const Duration(seconds: 5),
        positionOffset: 20,
        forwardAnimationCurve: Curves.decelerate,
        reverseAnimationCurve: Curves.easeInOut,
        flushbarPosition: FlushbarPosition.TOP,

      )..show(context)
  );
}

void showToast(String message , Color color){
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: color,
    textColor: Colors.white,
    fontSize: 16.0.sp,
  );
}

String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}


final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Color(0xff3094E8),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xff3094E8),
    foregroundColor: Colors.white,
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Color(0xff3094E8),
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Color(0xff3094E8),
  ),
);
