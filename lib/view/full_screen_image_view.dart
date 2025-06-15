import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullscreenImageView extends StatelessWidget {
  final String imageUrl;

  const FullscreenImageView({super.key, required this.imageUrl});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
        ),
      ),
    );
  }
}