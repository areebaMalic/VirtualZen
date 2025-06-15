import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constant.dart';
import '../viewModel/chat_view_model.dart';
import '../viewModel/forward_view_model.dart';
import '../viewModel/friends_view_model.dart';
import '../viewModel/profile_view_model.dart';

class ForwardScreen extends StatelessWidget {
  final List<String> messages;

  const ForwardScreen({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    final friendVM = Provider.of<FriendsViewModel>(context);
    final chatVM = Provider.of<ChatViewModel>(context, listen: false);
    final forwardVM = Provider.of<ForwardViewModel>(context);
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final profileVM = Provider.of<ProfileViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
            color:  Colors.white
        ),
        title: Text('Forward to',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Esteban',
        ),),
        actions: [
          IconButton(
            icon:  Icon(
              Icons.send,
              color:  Colors.white
            ),
            onPressed: () async {
              if (forwardVM.selectedFriendIds.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select at least one friend',
                  style: TextStyle(
                    fontFamily: 'Esteban',
                  ),)),
                );
                return;
              }

              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Forward',style:
                    TextStyle(
                      fontFamily: 'Esteban',
                    ),),
                  content: Text(
                    'Are you sure you want to forward ${messages.length} message(s) to ${forwardVM.selectedFriendIds.length} friend(s)?',
                    style: TextStyle(
                      fontFamily: 'Esteban',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child:  Text('Cancel',
                        style: TextStyle(
                            fontFamily: 'Esteban',
                            color: profileVM.isDarkMode ? Colors.white : Colors.black
                        ),),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: kFilledButtonColor,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child:  Text('Forward',
                      style: TextStyle(
                        color:  Colors.white,
                        fontFamily: 'Esteban',
                      ),),
                    ),
                  ],
                ),
              );

              if (confirm != true) return;

              for (var friend in friendVM.friends) {
                if (forwardVM.selectedFriendIds.contains(friend.id)) {
                  final friendId = friend.id;
                  final chatRoomId = currentUserId.compareTo(friendId) < 0
                      ? '${currentUserId}_$friendId'
                      : '${friendId}_$currentUserId';

                  for (String text in messages) {
                    await chatVM.forwardMessage(
                      targetChatRoomId: chatRoomId,
                      originalText: text,
                    );
                  }
                }
              }

              if (context.mounted) {
                forwardVM.clearSelections();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Messages forwarded',
                  style: TextStyle(
                    fontFamily: 'Esteban',
                  ),)),
                );
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: friendVM.friends.length,
        itemBuilder: (context, index) {
          final friend = friendVM.friends[index];
          final isSelected = forwardVM.selectedFriendIds.contains(friend.id);

          return ListTile(
            leading: CircleAvatar(
              child: friend.imageUrl != null && friend.imageUrl!.isNotEmpty
                  ? ClipOval(
                child: Image.network(friend.imageUrl!, width: 40.w, height: 40.h, fit: BoxFit.cover),
              )
                  : Text(friend.name[0].toUpperCase()),
            ),
            title: Text(capitalize(friend.name),
            style: TextStyle(
              fontFamily: 'Esteban',
            ),),
            subtitle: Text(friend.isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              fontFamily: 'Esteban',
            ),),
            trailing: Checkbox(
              activeColor: kFilledButtonColor,
              side: const BorderSide(
                  color: kFilledButtonColor
              ),
              value: isSelected,
              onChanged: (_) => forwardVM.toggleFriendSelection(friend.id),
            ),
            onTap: () => forwardVM.toggleFriendSelection(friend.id),
          );
        },
      ),
    );
  }
}