import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:virtual_zen/view/feed_screen.dart';
import 'offline_videos.dart';
import 'package:virtual_zen/utils/constant.dart';

class VideoFilterScreen extends StatefulWidget {
  const VideoFilterScreen({super.key});

  @override
  State<VideoFilterScreen> createState() => _VideoFilterScreenState();
}

class _VideoFilterScreenState extends State<VideoFilterScreen> {
  String selectedFilter = 'Online';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Stress Relief Videos",
          style: TextStyle(
            fontSize: 18.sp,
            fontFamily: 'Esteban',
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom-styled filter tabs
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16),
            child: Row(
              children: ['Online Videos', 'Offline Videos'].map((tab) {
                bool isSelected = selectedFilter == tab.split(" ")[0]; // 'Online' or 'Offline'
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedFilter = tab.split(" ")[0]; // Use only 'Online' or 'Offline'
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? kHighlightedTextColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Text(
                        tab,
                        style: TextStyle(
                          fontFamily: 'Esteban',
                          fontSize: 14.sp,
                          fontStyle: FontStyle.italic,
                          color: isSelected ? Colors.white : Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

       //   const Divider(),

          // Show content
          Expanded(
            child: selectedFilter == 'Online'
                ? const Feed()
                : const OfflineVideos(),
          ),
        ],
      ),
    );
  }
}
