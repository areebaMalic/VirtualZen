import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:virtual_zen/utils/constant.dart';
import '../viewModel/add_friend_view_model.dart';
import '../viewModel/profile_view_model.dart';

class AddFriendScreen extends StatelessWidget {
  const AddFriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileVM = Provider.of<ProfileViewModel>(context);
    final addFriendVM = Provider.of<AddFriendViewModel>(context);
    final user = profileVM.currentUser;

    return Scaffold(
      backgroundColor: profileVM.isDarkMode ? Colors.black : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30.h),
              Center(
                child: Text(
                  'Add by #pin',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Esteban',
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Center(
                child: Text(
                  addFriendVM.errorMessage.isEmpty
                      ? 'Ask your friend for their pin'
                      : addFriendVM.errorMessage,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontFamily: 'Esteban',
                    color: addFriendVM.errorMessage.isEmpty
                        ? Colors.grey
                        : Colors.red,
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              Container(
                height: 60.h,
                decoration: BoxDecoration(
                  color: profileVM.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Text('#', style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Esteban',
                        color: profileVM.isDarkMode ? Colors.white : Colors.black
                    )),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: TextField(
                        controller: addFriendVM.getPinController,
                        style: TextStyle(
                            fontSize: 18.sp,
                            fontFamily: 'Esteban',
                            fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter PIN',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontFamily: 'Esteban',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              Center(
                child: Text('Or send your pin to friends',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                    fontFamily: 'Esteban',
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "PIN: #${user?.pin}",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'Esteban',
                            fontWeight: FontWeight.w500,
                            color:  profileVM.isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: () {
                            final pin = user?.pin ?? '';
                            Clipboard.setData(ClipboardData(text: pin));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("PIN copied to clipboard",
                              style: TextStyle(
                                fontFamily: 'Esteban',
                              ),)),
                            );
                          },
                          child: Icon(Icons.copy, size: 18.sp, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Spacer(),
              Center(
                child: GestureDetector(
                  onTap: () async {
                    final result = await addFriendVM.sendRequest(
                      addFriendVM.getPinController.text,
                      user!,
                    );
                    if (context.mounted) {
                      if (result == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Request Sent')),
                        );
                        addFriendVM.errorMessage = '';
                      } else if (result == 'already_added') {
                        addFriendVM.errorMessage = 'friend already added';
                      } else {
                        addFriendVM.errorMessage = 'invalid pin';
                      }
                    }

                    addFriendVM.getPinController.clear();
                  },
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 60.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                     // color: kFilledButtonColor
                        gradient: LinearGradient(
                          colors: [Colors.green.shade400, Colors.yellow],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(Icons.arrow_forward, color: Colors.white, size: 30,),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
