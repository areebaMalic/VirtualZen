import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

enum VideoType { youtube, asset }

class PlayerScreen extends StatefulWidget {
  final String videoPath;
  final VideoType type;
  final String title;

  const PlayerScreen({super.key,
    required this.videoPath,
    required this.type,
    required this.title,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _assetController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();

    if (widget.type == VideoType.youtube) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: widget.videoPath,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: true,
        ),
      );
    } else {
      _assetController = VideoPlayerController.asset(widget.videoPath)
        ..initialize().then((_) {
          _chewieController = ChewieController(
            videoPlayerController: _assetController!,
            autoPlay: true,
            looping: false,
            fullScreenByDefault: true,
            allowFullScreen: true,
            allowMuting: true,
            materialProgressColors: ChewieProgressColors(
              playedColor: Colors.lightBlueAccent,
              handleColor: Colors.blueAccent,
              backgroundColor: Colors.grey,
              bufferedColor: Colors.white38,
            ),
          );
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _assetController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.type == VideoType.youtube
        ? YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _youtubeController!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.lightBlueAccent,
        bottomActions: const [
          CurrentPosition(),
          ProgressBar(isExpanded: true),
          RemainingDuration(),
          FullScreenButton(),
        ],
      ),
      builder: (context, player) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            widget.title,
            style: TextStyle(fontFamily: 'Esteban', color: Colors.white),
          ),
          backgroundColor: Colors.black87,
        ),
        body: Center(child: player),
      ),
    )
        : Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.title,
          style: const TextStyle(fontFamily: 'Esteban', color: Colors.white),
        ),
        backgroundColor: Colors.black87,
      ),
      body: Center(
        child: (_chewieController != null &&
            _chewieController!.videoPlayerController.value.isInitialized)
            ? AspectRatio(
          aspectRatio: _chewieController!
              .videoPlayerController.value.aspectRatio,
          child: Chewie(controller: _chewieController!),
        )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
