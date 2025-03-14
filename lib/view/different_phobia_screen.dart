import 'package:flutter/material.dart';

class HeightsHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Heights Therapy")),
      body: Center(child: Text("Height Exposure Therapy")),
    );
  }
}

class FlyingHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Flying Therapy")),
      body: Center(child: Text("Flying Exposure Therapy")),
    );
  }
}

class SpidersHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Spiders Therapy")),
      body: Center(child: Text("Spider Exposure Therapy")),
    );
  }
}
