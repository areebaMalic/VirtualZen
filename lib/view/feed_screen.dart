//feed screen



import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:virtual_zen/view/player_screen.dart';

class Feed extends StatelessWidget {
  const Feed({super.key});

  final List<String> videoIDs = const [
    'inpok4MKVLM', '9yj8mBfHlMk', 'grfXR6FAsI8', 'MR57rug8NsM',
    'c1Ndym-IsQg', 'ssss7V1_eyA', 'jOfshreyu4w', '78k-ZRRUgDU',
    'L1QOh-n-eus', 'WUASVHlfXeI', '40tPuU6jrgQ', 'ZToicYcHIOU',
    'W19PdslW7iw', 'O-6f5wQXSu8', '1vx8iUvfyCY', 'MIr3RsUWrdo',
    'Fpiw2hH-dlc', 'U9YKY7fdwyg', 'qzR62JJCMBQ', '6p_yaNFSYao',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: IconThemeData(
              color: Colors.white
          ),
          title: const Text('Stress Relief Videos',style: TextStyle(
        color: Colors.white,
        fontFamily: 'Esteban',
      ),)),
      body: ListView.builder(
        itemCount: videoIDs.length,
        itemBuilder: (context, index) {
          final videoID = videoIDs[index];
          final thumbnailUrl = 'https://img.youtube.com/vi/$videoID/hqdefault.jpg';

          return InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PlayerScreen(videoId: videoID),
                ),
              );
            },
            child: Card(
              margin:  EdgeInsets.all(8.0.w),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    thumbnailUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200.h,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text('Thumbnail not available', style:
                          TextStyle(
                            color: Colors.black54,
                            fontFamily: 'Esteban',
                          )),
                        ),
                      );
                    },
                  ),
                  const Icon(
                    Icons.play_circle_fill,
                    size: 64,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
