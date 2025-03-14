/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_zen/utils/routes/route_name.dart';
import '../viewModel/phobia_view_model.dart';

class PhobiaListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final phobiaProvider = Provider.of<PhobiaViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Select Your Phobia"),
      ),
      body: ListView.builder(
        itemCount: phobiaProvider.phobias.length,
        itemBuilder: (context, index) {
          final phobia = phobiaProvider.phobias[index];

          return GestureDetector(
            onTap: () {
              if(phobia.routeName == "spider") {
                Navigator.pushReplacementNamed(context, RouteName.spider);
              }
              else if(phobia.routeName == "height") {
                Navigator.pushReplacementNamed(context, RouteName.height);
              }
             else if(phobia.routeName == "flying") {
                Navigator.pushReplacementNamed(context, RouteName.flying);
              }
             else{

              }
            },
            child: Card(
           //   color: Color(0xFFC8C8C8),
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: Color(0xFFD0D1CE),
                  radius: 24,
                  child: Image.asset(
                    phobia.iconPath,
                    width: 35,
                    height: 35,
                  //  fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  phobia.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(phobia.scientificName),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
          );
        },
      ),

    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virtual_zen/utils/routes/route_name.dart';
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
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: Color(0xFFD0D1CE),
                  radius: 24,
                  child: Image.asset(phobia.iconPath, width: 35, height: 35),
                ),
                title: Text(phobia.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text(phobia.scientificName),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
          );
        },
      ),
    );
  }
}