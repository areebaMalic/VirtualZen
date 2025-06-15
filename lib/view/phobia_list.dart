/*
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/routes/route_name.dart';
import '../viewModel/phobia_view_model.dart';

class PhobiaListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final phobiaProvider = Provider.of<PhobiaViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Select Your Phobia",
      style: TextStyle(
        fontFamily: 'Esteban',
      ),)),
      body: ListView.builder(
        itemCount: phobiaProvider.phobias.length,
        itemBuilder: (context, index) {
          final phobia = phobiaProvider.phobias[index];

          return GestureDetector(
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('selectedPhobia', phobia.routeName);
              Navigator.pushReplacementNamed(context, RouteName.bottomBar);
            },
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12).r),
              child: ListTile(
                contentPadding: EdgeInsets.all(16).r,
                leading: CircleAvatar(
                  backgroundColor: Color(0xFFD0D1CE),
                  radius: 24.r,
                  child: Image.asset(phobia.iconPath, width: 35.w, height: 35.h),
                ),
                title: Text(phobia.name, style: TextStyle(
                    fontSize: 18.sp,
                    fontFamily: 'Esteban',
                    fontWeight: FontWeight.bold)),
                subtitle: Text(phobia.scientificName,
                style: TextStyle(
                  fontFamily: 'Esteban',),),
                //   trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
          );
        },
      ),
    );
  }
}*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../utils/routes/route_name.dart';
import '../viewModel/page_view_model.dart';
import '../viewModel/phobia_view_model.dart';

class PhobiaListScreen extends StatelessWidget {
  Future<void> _onPhobiaSelected(BuildContext context, String routeName) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      // Update selected phobia in Firebase
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'selectedPhobia': routeName,
      });

      // Update app state (PageViewModel)
      final pageVM = Provider.of<PageViewModel>(context, listen: false);
      await pageVM.updatePhobia(routeName);

      // Navigate to bottom bar
      Navigator.pushNamedAndRemoveUntil(
          context, RouteName.bottomBar, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final phobiaProvider = Provider.of<PhobiaViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Select Your Phobia",
          style: TextStyle(
            fontFamily: 'Esteban',
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: phobiaProvider.phobias.length,
        itemBuilder: (context, index) {
          final phobia = phobiaProvider.phobias[index];

          return GestureDetector(
            onTap: () => _onPhobiaSelected(context, phobia.routeName),
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              child: ListTile(
                contentPadding: EdgeInsets.all(16.r),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFD0D1CE),
                  radius: 24.r,
                  child: Image.asset(phobia.iconPath, width: 35.w, height: 35.h),
                ),
                title: Text(
                  phobia.name,
                  style: TextStyle(
                      fontSize: 18.sp,
                      fontFamily: 'Esteban',
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  phobia.scientificName,
                  style: TextStyle(
                    fontFamily: 'Esteban',
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
