import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:virtual_zen/view/player_screen.dart' as myplayer;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  final List<String> videoIDs = const [
    'inpok4MKVLM', '9yj8mBfHlMk', 'grfXR6FAsI8', 'MR57rug8NsM',
    'c1Ndym-IsQg', 'ssss7V1_eyA', 'jOfshreyu4w', '78k-ZRRUgDU',
    'L1QOh-n-eus', 'WUASVHlfXeI', '40tPuU6jrgQ', 'ZToicYcHIOU',
    'W19PdslW7iw', 'O-6f5wQXSu8', '1vx8iUvfyCY', 'MIr3RsUWrdo',
    'Fpiw2hH-dlc', 'U9YKY7fdwyg', 'qzR62JJCMBQ', '6p_yaNFSYao',
  ];

  Map<String, String> titles = {};

  @override
  void initState() {
    super.initState();
    fetchAllTitles();
  }

  Future<void> fetchAllTitles() async {
    final yt = YoutubeExplode();
    for (var id in videoIDs) {
      try {
        var video = await yt.videos.get(id);
        if (mounted) {
          titles[id] = video.title;
        }
      } catch (_) {
        if (mounted) {
          titles[id] = 'Unknown Title';
        }
      }
    }
    yt.close();

    if (mounted) setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        itemCount: videoIDs.length,
        itemBuilder: (context, index) {
          final videoID = videoIDs[index];
          final thumbnailUrl = 'https://img.youtube.com/vi/$videoID/hqdefault.jpg';

          return InkWell(
              onTap: () async {
                String title = titles[videoID] ?? '';

                if (title.isEmpty) {
                  // Show loader dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    var yt = YoutubeExplode();
                    var video = await yt.videos.get(videoID);
                    title = video.title;
                    yt.close();

                    // Cache it for future
                    if (mounted) {
                      setState(() {
                        titles[videoID] = title;
                      });
                    }
                  } catch (_) {
                    title = "YouTube Video";
                  }

                  Navigator.pop(context); // Remove loading dialog
                }

                // Navigate after title is fetched
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => myplayer.PlayerScreen(
                      videoPath: videoID,
                      type: myplayer.VideoType.youtube,
                      title: title,
                    ),
                  ),
                );
              },
              child: Card(
              margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    thumbnailUrl,
                    width: double.infinity,
                    height: 200.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200.h,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text('Thumbnail not available',
                              style: TextStyle(
                                color: Colors.black54,
                                fontFamily: 'Esteban',
                              )),
                        ),
                      );
                    },
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
            ),
          );
        },
      ),
    );
  }
}
