import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'player_screen.dart';

class VideoItem extends StatefulWidget {
  final String assetPath;

  const VideoItem({required this.assetPath, super.key});

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlayerScreen(
                videoPath: widget.assetPath,
                type: VideoType.asset,
                title: widget.assetPath.split('/').last

            ),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black45,
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Icon(Icons.play_arrow, size: 48, color: Colors.white),
            ),
          ),
        ],
      ),
    )
        : const SizedBox(
      height: 200,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
