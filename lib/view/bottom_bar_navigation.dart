import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:virtual_zen/viewModel/page_view_model.dart';
import '../utils/constant.dart';
import '../utils/routes/route_name.dart';
import 'home_screen.dart';

class BottomBarScreen extends StatelessWidget {
  BottomBarScreen({super.key});


  // List of screens to switch between
  final List<Widget> screens = [
    const HomeScreen(),
    /* const TransactionScreen(),
    const BudgetScreen(),
    const ProfileScreen(),*/
  ];

  @override
  Widget build(BuildContext context) {

    final navigationProvider = Provider.of<PageViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, RouteName.login);
              },
              icon: const Icon(Icons.logout)),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            fontFamily: 'Esteban',
            color: kFilledButtonColor
        ),
        selectedItemColor: kFilledButtonColor,
        unselectedItemColor: kLightTextColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: kLightTextColor, size: 30,),
            label: 'Home',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.people, color: kLightTextColor, size: 30),
              label: 'Community'),
          BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart, color: kLightTextColor, size: 30),
              label: 'Budget'),
          BottomNavigationBarItem(
              icon: Icon(Icons.perm_identity, color: kLightTextColor, size: 30),
              label: 'Profile'),
        ],
        currentIndex: navigationProvider.currentIndex,
        onTap: (index) {
          navigationProvider.setCurrentNavigationIndex(index);
        },
      ),
    );
  }
}