
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../viewModel/auth_view_model.dart';
import '../constant.dart';

class TermConditionCheckbox extends StatelessWidget {

  final String text;
  final String coloredText;
  const TermConditionCheckbox({
    required this.text,
    required this.coloredText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
        children: [
          Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              return Checkbox(
                value: authViewModel.isChecked,
                onChanged:(bool? value){
                  authViewModel.toggleCheckBoxValue(value!);
                },
                side: const BorderSide(
                    color: kFilledButtonColor
                ),
                activeColor: kFilledButtonColor,
              );
            },),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: text,
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Esteban',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500
                ),
                children: [
                  TextSpan(
                      text: coloredText,
                      style: const TextStyle( color: kHighlightedTextColor)
                  )
                ] ,
              ),
            ),
          )

        ]
    );
  }
}