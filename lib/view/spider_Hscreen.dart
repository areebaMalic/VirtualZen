import 'package:flutter/material.dart';

class SpidersHomePage extends StatelessWidget {
  const SpidersHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Spider Exposure Therapy",
      style: TextStyle(
        fontFamily: 'Esteban',
      ),)),
    );
  }
}