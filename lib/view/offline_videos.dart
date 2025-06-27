import 'package:flutter/cupertino.dart';
import 'package:virtual_zen/view/video_item.dart';

class OfflineVideos extends StatelessWidget {
  const OfflineVideos({super.key});

  final List<String> videoPaths = const [
    'assets/videos/video_1.mp4',
    'assets/videos/video_2.mp4',
    'assets/videos/video_3.mp4',
    'assets/videos/video_4.mp4',
    'assets/videos/video_5.mp4',
    'assets/videos/video_6.mp4',
    'assets/videos/video_7.mp4',
    'assets/videos/video_8.mp4',
    'assets/videos/video_9.mp4',
    'assets/videos/video_10.mp4',
    'assets/videos/video_11.mp4',
    'assets/videos/video_12.mp4',
    'assets/videos/video_13.mp4',
    'assets/videos/video_14.mp4',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: videoPaths.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: VideoItem(assetPath: videoPaths[index]),
        );
      },
    );
  }
}
