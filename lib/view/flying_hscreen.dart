import 'package:flutter/material.dart';

class FlyingHomePage extends StatelessWidget {
  const FlyingHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Flying Exposure Therapy",
        style: TextStyle(
        fontFamily: 'Esteban',
      ),)),
    );
  }
}