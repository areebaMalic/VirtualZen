import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../utils/constant.dart';
import '../utils/routes/route_name.dart';
import '../viewModel/chat_view_model.dart';
import '../viewModel/friends_view_model.dart';
import '../viewModel/profile_view_model.dart';
class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final friendsVm = Provider.of<FriendsViewModel>(context);
    final profileVM = Provider.of<ProfileViewModel>(context);

    // Sort friends by the time the last message was sent (descending order)
    friendsVm.friends.sort((a, b) {
      if (a.lastMessageTime == null || b.lastMessageTime == null) {
        return 0; // No sorting if times are not available
      }
      return b.lastMessageTime!.compareTo(a.lastMessageTime!); // Sort by lastMessageTime descending
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Friends (${friendsVm.friendCount})', style: TextStyle(fontSize: 18.sp, color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(15.w),
            child: TextField(
              onChanged: friendsVm.searchFriends,
              decoration: InputDecoration(
                hintText: 'Search friends by name or PIN',
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: const BorderSide(
                      color: kHighlightedTextColor,
                    )),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(
                    color: Colors.white
                  )
                ),
                prefixIcon: Icon(Icons.search, size: 20.sp),
              ),

              cursorColor: kHighlightedTextColor,
            ),
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: friendsVm.friends.isEmpty
                ? Center(
              child: Text(
                'No friends added yet',
                style: TextStyle(fontSize: 14.sp),
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              itemCount: friendsVm.friends.length,
              itemBuilder: (_, i) {
                final friend = friendsVm.friends[i];

                final currentUserId = FirebaseAuth.instance.currentUser!.uid;
                final friendId = friend.id;

                final chatRoomId = currentUserId.compareTo(friendId) < 0
                    ? '${currentUserId}_$friendId'
                    : '${friendId}_$currentUserId';

                return Card(
                  margin: EdgeInsets.only(bottom: 10.h),
                  child: ListTile(
                    tileColor: profileVM.isDarkMode? Colors.black12 : Colors.white70,
                    onTap: () async {
                      final chatVM = Provider.of<ChatViewModel>(context, listen: false);
                      chatVM.setChatRoomId(chatRoomId);
                      chatVM.setFriendId(friendId);
                      chatVM.setFriendName(friend.name);
                      chatVM.setFriendImageUrl(friend.imageUrl);
                      chatVM.resetInitialScroll();

                      // Mark as read (unreadCount -> 0)
                      await chatVM.markMessagesAsRead(chatRoomId);
                      await Future.delayed(Duration(milliseconds: 10));

                      Navigator.pushNamed(context, RouteName.chat).then((_) {
                        friendsVm.updateUnreadCount(friendId);
                        chatVM.clearSelection();
                        chatVM.clearReply();
                      });
                    },
                    leading: CircleAvatar(
                      child: friend.imageUrl != null && friend.imageUrl!.isNotEmpty
                          ? ClipOval(
                        child: Image.network(friend.imageUrl!, width: 40.w, height: 40.h, fit: BoxFit.cover),
                      )
                          : Text(friend.name[0].toUpperCase()),
                    ),
                    title: Text(
                      friend.name,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: friend.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: friend.lastMessage != null && friend.lastMessage!.isNotEmpty
                        ? Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        friend.lastMessage!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[700],
                          fontWeight: friend.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                        : SizedBox(height: 2.h),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}