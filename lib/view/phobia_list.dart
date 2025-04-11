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
      appBar: AppBar(title: Text("Select Your Phobia")),
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
                title: Text(phobia.name, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                subtitle: Text(phobia.scientificName),
                //   trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
          );
        },
      ),
    );
  }
}