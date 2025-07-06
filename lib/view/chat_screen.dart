import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:virtual_zen/utils/constant.dart';
import '../utils/components/filled_button_design.dart';
import '../viewModel/chat_view_model.dart';
import '../viewModel/friends_view_model.dart';
import '../viewModel/profile_view_model.dart';
import 'forward_screen.dart';
import 'full_screen_image_view.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});

  final Map<String, GlobalKey> messageKeys = {};
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ChatViewModel>(context);
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final chatRoomId = viewModel.chatRoomId!;
    final friendID = viewModel.friendId;
    final inputController = viewModel.inputController;
    final profileVM = Provider.of<ProfileViewModel>(context);
    final user = profileVM.currentUser;


    void showFriendDetailsSheet(BuildContext rootContext, ChatViewModel viewModel, ProfileViewModel profileVM) {
      final friendsVM = Provider.of<FriendsViewModel>(context, listen: false);


      showModalBottomSheet(
        context: rootContext,
        backgroundColor: profileVM.isDarkMode ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        builder: (context) {
          return Padding(
            padding:  EdgeInsets.all(16.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Friend Details',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Esteban',
                    color: profileVM.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Name: ${viewModel.friendName ?? 'Unknown'}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: 'Esteban',
                    color: profileVM.isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'PIN: ${user?.pin}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontFamily: 'Esteban',
                    color: profileVM.isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                StreamBuilder<DocumentSnapshot>(
                  stream: viewModel.getFriendStatusStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) {
                      return const SizedBox.shrink();
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>?;

                    if (data == null) {
                      return const SizedBox.shrink();
                    }

                    final isOnline = data['isOnline'] ?? false;
                    final lastSeen = data['lastSeen'];

                    if (isOnline == true) {
                      return Text(
                        'Online',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: 'Esteban',
                          color: profileVM.isDarkMode ? Colors.white60 : Colors.black54,
                        ),
                      );
                    } else if (lastSeen != null && lastSeen is Timestamp) {
                      final dateTime = lastSeen.toDate();
                      final now = DateTime.now();

                      final isToday = now.year == dateTime.year &&
                          now.month == dateTime.month &&
                          now.day == dateTime.day;

                      final time = TimeOfDay.fromDateTime(dateTime).format(context);
                      final formattedDate = '${dateTime.day.toString().padLeft(2, '0')}/'
                          '${dateTime.month.toString().padLeft(2, '0')}/'
                          '${dateTime.year}';

                      return Text(
                        isToday ? 'Last seen $time' : 'Last seen $formattedDate at $time',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: 'Esteban',
                          color: profileVM.isDarkMode ? Colors.white60 : Colors.black54,
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
                SizedBox(height: 24.h),
                FilledButtonDesign(
                  title: 'Unfriend',
                  press: () async {
                    Navigator.pop(rootContext); // close the bottom sheet
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext dialogContext) => AlertDialog(
                        title:  Text('Unfriend',
                          style: TextStyle(
                              fontFamily: 'Esteban',
                              fontSize: 30.sp
                          ),),
                        content: const Text('Are you sure you want to unfriend this user?',
                          style: TextStyle(
                            fontFamily: 'Esteban',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(false),
                            child: const Text('Cancel',
                              style: TextStyle(
                                fontFamily: 'Esteban',
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(true),
                            child: const Text('Unfriend',
                              style: TextStyle(
                                fontFamily: 'Esteban',
                              ),),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await viewModel.unfriend(currentUserId, friendID!, friendsVM);

                      if (rootContext.mounted) {
                        Navigator.pop(rootContext); // ✅ This will go back to the Community screen

                        ScaffoldMessenger.of(rootContext).showSnackBar(
                          const SnackBar(content: Text('User unfriended',
                            style: TextStyle(
                              fontFamily: 'Esteban',
                            ),)),
                        );
                      }
                    }
                  },
                ),
                SizedBox(height: 16.h),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: profileVM.isDarkMode ? Colors.white : Colors.black
        ),
        backgroundColor: profileVM.isDarkMode ?  Colors.black : Colors.white,
        leading: viewModel.isSelectionMode
            ? IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => viewModel.clearSelection(),
        )
            : null,
        title: viewModel.isSelectionMode
            ? Text(
          '${viewModel.selectedMessageIds.length} selected',
          style:  TextStyle(
            fontSize: 18.sp,
            fontFamily: 'Esteban',
            color: profileVM.isDarkMode ? Colors.white: Colors.black,
          ),
        )
            : Row(
          children: [
             CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              backgroundImage: viewModel.friendImageUrl != null &&
                  viewModel.friendImageUrl!.isNotEmpty
                  ? NetworkImage(viewModel.friendImageUrl!)
                  : null,
              child: viewModel.friendImageUrl == null ||
                  viewModel.friendImageUrl!.isEmpty
                  ? Text(
                viewModel.friendName![0].toUpperCase(),
                style:  TextStyle(
                    fontSize: 18.sp,
                    fontFamily: 'Esteban',
                    color: Colors.black),
              )
                  : null,
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewModel.friendName![0].toUpperCase() + viewModel.friendName!.substring(1),
                  style:  TextStyle(
                    fontSize: 18.sp,
                    fontFamily: 'Esteban',
                    color: profileVM.isDarkMode ? Colors.white: Colors.black,
                  ),
                ),
                StreamBuilder<DocumentSnapshot>(
                  stream: viewModel.getFriendStatusStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) {
                      return const SizedBox.shrink();
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>?;

                    if (data == null) {
                      return const SizedBox.shrink();
                    }

                    final isOnline = data['isOnline'] ?? false;
                    final lastSeen = data['lastSeen'];

                    if (isOnline == true) {
                      return Text(
                        'Online',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: 'Esteban',
                          color: profileVM.isDarkMode ? Colors.white60 : Colors.black54,
                        ),
                      );
                    } else if (lastSeen != null && lastSeen is Timestamp) {
                      final dateTime = lastSeen.toDate();
                      final now = DateTime.now();

                      final isToday = now.year == dateTime.year &&
                          now.month == dateTime.month &&
                          now.day == dateTime.day;

                      final time = TimeOfDay.fromDateTime(dateTime).format(context);
                      final formattedDate = '${dateTime.day.toString().padLeft(2, '0')}/'
                          '${dateTime.month.toString().padLeft(2, '0')}/'
                          '${dateTime.year}';

                      return Text(
                        isToday ? 'Last seen $time' : 'Last seen $formattedDate at $time',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: 'Esteban',
                          color: profileVM.isDarkMode ? Colors.white60 : Colors.black54,
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                )

              ],
            ),
            Spacer(),
            PopupMenuButton<String>(
              offset: const Offset(0, 40), // dropdown below the button
              color: profileVM.isDarkMode ? Colors.grey[900] : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
              elevation: 8,
              icon: Icon(
                Icons.more_vert,
                size: 26,
                color: profileVM.isDarkMode ? Colors.white : Colors.black,
              ),
              onSelected: (value) {
                if (value == 'details') {
                  showFriendDetailsSheet(context, viewModel, profileVM);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'details',
                  height: 40.h,
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 25, color: Colors.deepPurple),
                      SizedBox(width: 10.w),
                      Text(
                        'Details',
                        style: TextStyle(
                          fontFamily: 'Esteban',
                          fontSize: 16.sp,
                          color: profileVM.isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )

          ],
        ),
        actions: viewModel.isSelectionMode
            ? [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () async {
              final messages = await FirebaseFirestore.instance
                  .collection('chatRooms')
                  .doc(chatRoomId)
                  .collection('messages')
                  .get();
              viewModel.copySelectedMessages(context, messages.docs);
            },
          ),
          IconButton(
            icon: const Icon(Icons.forward),
            onPressed: () async {
              final messages = await FirebaseFirestore.instance
                  .collection('chatRooms')
                  .doc(chatRoomId)
                  .collection('messages')
                  .get();
              final texts = viewModel.getSelectedTexts(messages.docs);
              if (texts.isEmpty) return;
              viewModel.clearSelection();
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ForwardScreen(messages: texts),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final isCurrentUserSender = await Future.wait(
                viewModel.selectedMessageIds
                    .map((id) => viewModel.isSentByCurrentUser(chatRoomId, id)),
              );

              final confirm = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Messages', style: TextStyle(
                    fontFamily: 'Esteban',
                  ),),
                  content: const Text('Do you want to delete the selected message(s)?',
                  style: TextStyle(
                    fontFamily: 'Esteban',
                  ),),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'me'),
                      child: const Text('Delete for Me',
                      style: TextStyle(
                        fontFamily: 'Esteban',
                      ),),
                    ),
                    if (isCurrentUserSender.every((isSender) => isSender))
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'everyone'),
                        child: const Text('Delete for Everyone',
                        style: TextStyle(
                          fontFamily: 'Esteban',
                        ),),
                      ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel',
                      style: TextStyle(
                        fontFamily: 'Esteban',
                      ),),
                    ),
                  ],
                ),
              );
              if (confirm == 'me') {
                final confirmDelete = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Deletion',
                      style: TextStyle(
                        fontFamily: 'Esteban',
                      ),
                    ),
                    content: const Text('Are you sure you want to delete for yourself?',
                      style: TextStyle(
                        fontFamily: 'Esteban',
                      ),),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel',
                          style: TextStyle(
                            fontFamily: 'Esteban',
                          ),),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Yes, Delete',
                          style: TextStyle(
                            fontFamily: 'Esteban',
                          ),),
                      ),
                    ],
                  ),
                );
                if (confirmDelete == true) {
                  await viewModel.deleteSelectedMessages(chatRoomId);
                }
              } else if (confirm == 'everyone') {
                final confirmDeleteEveryone = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Deletion',
                      style: TextStyle(
                        fontFamily: 'Esteban',
                      ),),
                    content: const Text('Delete message(s) for everyone? This cannot be undone.',
                      style: TextStyle(
                        fontFamily: 'Esteban',
                      ),),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel',
                          style: TextStyle(
                            fontFamily: 'Esteban',
                          ),),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Yes, Delete for Everyone',
                          style: TextStyle(
                            fontFamily: 'Esteban',
                          ),),
                      ),
                    ],
                  ),
                );
                if (confirmDeleteEveryone == true) {
                  await viewModel.deleteSelectedMessagesForEveryone(chatRoomId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Message(s) deleted for everyone',
                      style: TextStyle(
                        fontFamily: 'Esteban',
                      ),)),
                  );
                }
              }
            },
          ),
        ]
            : [],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: viewModel.getMessages(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (viewModel.shouldAutoScroll && messages.isNotEmpty) {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (viewModel.scrollController.hasClients) {
                        viewModel.scrollController.animateTo(
                          viewModel.scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                        viewModel.setAutoScroll(false); // Disable until next manual send
                      }
                    });
                  }
                  if (!viewModel.hasScrolledInitially && messages.isNotEmpty) {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (viewModel.scrollController.hasClients) {
                        viewModel.scrollController.jumpTo(
                          viewModel.scrollController.position.maxScrollExtent,
                        );
                        viewModel.hasScrolledInitially = true;
                      }
                    });
                  }
                });

                /// Find the last sent message by current user that has been seen
                final docs = snapshot.data!.docs;

                final lastSeenMessageId = docs
                    .where((msg) {
                  final data = msg.data() as Map<String, dynamic>;
                  final isSeen = data['seen'] == true;
                  final isSender = data['senderId'] == currentUserId;
                  final isDeleted = data.containsKey('deleted') ? data['deleted'] == true : false;
                  return isSeen && isSender && !isDeleted;
                })
                    .map((msg) => msg.id)
                    .lastOrNull;

                return ListView.builder(
                  controller: viewModel.scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final data = msg.data() as Map<String, dynamic>;

                    /// 🔹 Mark as seen if it's a friend's message and not seen
                    Future.delayed(const Duration(milliseconds: 300), () {
                      final lastMessage = messages.last;
                      final data = lastMessage.data() as Map<String, dynamic>;

                      final isFromFriend = data['senderId'] != currentUserId;
                      final isUnseen = data['seen'] != true;
                      final isDeleted = data['deleted'] == true;

                      if (isFromFriend && isUnseen && !isDeleted) {
                        FirebaseFirestore.instance
                            .collection('chatRooms')
                            .doc(chatRoomId)
                            .collection('messages')
                            .doc(lastMessage.id)
                            .update({'seen': true});
                      }
                    });

                    final isSender = data['senderId'] == currentUserId;
                    final isSelected = viewModel.isSelected(msg.id);
                    final isDeleted = data['deleted'] == true;
                    final replyText = data['replyText'];
                    final replyToId = data['replyTo'];
                    final reactions = List<Map<String, dynamic>>.from(data['reactions'] ?? []);
                    final key = GlobalKey();
                    messageKeys[msg.id] = key;
                    final isSeenByFriend = isSender && data['seen'] == true && msg.id == lastSeenMessageId;


                    if (isDeleted) return const SizedBox.shrink();
                    return KeyedSubtree(
                      key: key,
                      child: Align(
                        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                        child: GestureDetector(
                          onLongPress: () async {
                            if (viewModel.isSelectionMode) {
                              viewModel.toggleSelectionMode(msg.id);
                            }
                            else {
                              final emoji = await showDialog<String>(
                                context: context,
                                barrierColor: Colors.transparent,
                                builder: (context) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white54,
                                      borderRadius: BorderRadius.circular(30.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        for (var emoji in ['👍', '❤️', '😂', '😮', '😢', '🙏'])
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context, emoji);
                                            },
                                            child: Padding(
                                              padding:  EdgeInsets.symmetric(horizontal: 6.w),
                                              child: Text(emoji, style:  TextStyle(fontSize: 24.sp, fontFamily: 'Esteban',)),
                                            ),
                                          ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context, 'custom_picker');
                                          },
                                          child:  Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 6.w),
                                            child: Icon(Icons.add_circle_outline, color: Colors.black54, size: 28),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );

                              if (emoji != null && emoji != 'custom_picker') {
                                viewModel.toggleReaction(chatRoomId, msg.id, emoji);
                              } else if (emoji == 'custom_picker') {
                                /// Open full emoji picker as bottom sheet
                                final selectedEmoji = await showModalBottomSheet<String>(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  isScrollControlled: true,
                                  builder: (context) {
                                    return DraggableScrollableSheet(
                                      initialChildSize: 0.5,
                                      maxChildSize: 0.9,
                                      minChildSize: 0.3,
                                      builder: (context, scrollController) {
                                        return Container(
                                          decoration:  BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                                          ),
                                          child: EmojiPicker(
                                            onEmojiSelected: (category, emoji) {
                                              Navigator.pop(context, emoji.emoji);
                                            },
                                            config: Config(
                                              height: 256.h,
                                              emojiViewConfig: EmojiViewConfig(
                                                emojiSizeMax: 28 *
                                                    (foundation.defaultTargetPlatform == TargetPlatform.iOS ? 1.20 : 1.0),
                                              ),
                                              checkPlatformCompatibility: true,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );

                                if (selectedEmoji != null) {
                                  viewModel.toggleReaction(chatRoomId, msg.id, selectedEmoji);
                                }
                              }
                              viewModel.toggleSelectionMode(msg.id);

                            }
                          },
                          onTap: () {
                            if (viewModel.isSelectionMode) {
                              viewModel.toggleSelectionMode(msg.id);
                            }
                          },
                          onHorizontalDragUpdate: (details) {
                            if (details.delta.dx > 10) {
                              viewModel.setReplyMessageId(msg.id);
                              viewModel.setReplyText(data['text']);
                            }
                          },
                          child: Container(
                            margin:  EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                            padding:  EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: viewModel.isHighlighted(msg.id)
                                  ? (isSender ? Colors.blue.shade200 : Colors.grey.shade300) // lighter color on highlight
                                  : isSelected
                                  ? Colors.blueGrey.shade200
                                  : isSender
                                  ? Colors.blue.shade100
                                  : Colors.grey.shade300,
                              border: null,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Message bubble
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context).size.width * 0.60, // 75% of screen width
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Forwarded label
                                          if (data['isForwarded'] == true)
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.shortcut, size: 14, color: Colors.grey),
                                                 SizedBox(width: 4.w),
                                                Text(
                                                  'Forwarded',
                                                  style: TextStyle(
                                                    fontSize: 11.sp,
                                                    fontStyle: FontStyle.italic,
                                                    fontFamily: 'Esteban',
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          // Reply-to message
                                          if (replyText != null)
                                            GestureDetector(
                                              onTap: () async {
                                                if (replyToId != null && messageKeys.containsKey(replyToId)) {
                                                  final key = messageKeys[replyToId]!;
                                                  final ctx = key.currentContext;
                                                  if (ctx != null) {
                                                    Scrollable.ensureVisible(
                                                      ctx,
                                                      duration: const Duration(milliseconds: 400),
                                                      alignment: 0.5, // Center it
                                                      curve: Curves.easeInOut,
                                                    ).then((_) {
                                                      viewModel.setHighlightedMessageId(replyToId);
                                                      // Clear after 2 sec
                                                      Future.delayed(const Duration(seconds: 2), () {
                                                        viewModel.clearHighlightedMessageId();
                                                      });
                                                    });
                                                  }
                                                }
                                              },
                                              child: Container(
                                                margin:  EdgeInsets.only(top: 4.h),
                                                padding:  EdgeInsets.all(8.r),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade300, // light background
                                                  borderRadius: BorderRadius.circular(8.r),
                                                ),
                                                width: 100.w, // <-- full width
                                                child: Text(
                                                  replyText,
                                                  style:  TextStyle(
                                                      fontSize: 14.sp,
                                                      fontFamily: 'Esteban',
                                                      color: Colors.black87),
                                                ),
                                              ),
                                            ),
                                          // Main message text
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Flexible(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    if (data.containsKey('imageUrl') && data['imageUrl'] != null)
                                                      GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (_) => FullscreenImageView(imageUrl: data['imageUrl']),
                                                            ),
                                                          );
                                                        },
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(8.r),
                                                          child: Image.network(
                                                            data['imageUrl'],
                                                            width: 200.w,
                                                            height: 200.h,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    if (data.containsKey('text') && (data['text']?.toString().trim().isNotEmpty ?? false))
                                                      Padding(
                                                        padding: EdgeInsets.only(top: 4.h),
                                                        child: Text(
                                                          data['text'],
                                                          style: TextStyle(
                                                            fontSize: 14.sp,
                                                            fontFamily: 'Esteban',
                                                            color: Colors.black87,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 50.w),
                                              if (data['timestamp'] != null)
                                                Text(
                                                  TimeOfDay.fromDateTime((data['timestamp'] as Timestamp).toDate()).format(context),
                                                  style:  TextStyle(
                                                      fontSize: 10.sp,
                                                      fontFamily: 'Esteban',
                                                      color: Colors.grey),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Reactions floating outside
                                    if (reactions.isNotEmpty)
                                      Positioned(
                                        bottom: -30, // move it slightly outside below bubble
                                        left: isSender ? null : 0,
                                        right: isSender ? 0 : null,
                                        child: Container(
                                          padding:  EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(20.r),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.1),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Wrap(
                                            spacing: 5,
                                            children: reactions.map((reaction) {
                                              final emoji = reaction['emoji'] ?? '';
                                              return GestureDetector(
                                                onTap: () {
                                                  viewModel.toggleReaction(chatRoomId, msg.id, emoji);
                                                },
                                                child: Text(emoji, style:  TextStyle(
                                                    fontSize: 16.sp,
                                                  fontFamily: 'Esteban',
                                                )),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),

                                    /// "Seen" label outside the message bubble
                                    if (isSeenByFriend)
                                      Positioned(
                                        bottom: -25, // Positioning it outside and below the message bubble
                                        right: isSender ? 0 : null,
                                        left: isSender ? null : 0,
                                        child: Text(
                                          'Seen',
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            fontFamily: 'Esteban',
                                            color: Colors.grey[600],
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),

                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          if (viewModel.replyMessageId != null && viewModel.replyText != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              margin:  EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border(left: BorderSide(width: 4.w, color: Colors.blue.shade300)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      viewModel.replyText!,
                      style: const TextStyle(
                        fontFamily: 'Esteban',
                        color: Colors.black87,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: viewModel.clearReply,
                  ),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.all(8.0.r),
            child: Row(
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 120.h, // WhatsApp-style limit
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: profileVM.isDarkMode ? Colors.grey : Colors.white,
                        borderRadius: BorderRadius.circular(25.r),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: inputController,
                        maxLines: null, // allow multiline
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline, // Enter goes to new line
                        onSubmitted: (text) {
                          if (text.trim().isEmpty) return;
                          viewModel.sendMessage(
                            chatRoomId,
                            text.trim(),
                            replyToId: viewModel.replyMessageId,
                          );
                          viewModel.setAutoScroll(true);
                          inputController.clear();
                          viewModel.clearReply();
                        },
                        decoration: InputDecoration(
                          hintText: "Type a message",
                          hintStyle: TextStyle(
                              fontSize: 14.sp,
                              fontFamily: 'Esteban',
                              color: profileVM.isDarkMode ? Colors.black : Colors.grey.shade400
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'Esteban',
                            color: Colors.black ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.photo),
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 70, // compress quality
                      maxWidth: 1080,
                    );
                    if (pickedFile != null) {
                      await viewModel.sendImage(chatRoomId, pickedFile, replyToId: viewModel.replyMessageId);
                      viewModel.scrollToBottom();
                      viewModel.clearReply();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final text = inputController.text.trim();
                    if (text.isEmpty) return;
                    viewModel.sendMessage(
                      chatRoomId,
                      text,
                      replyToId: viewModel.replyMessageId,
                    );
                    viewModel.scrollToBottom();
                    inputController.clear();
                    viewModel.clearReply();
                    viewModel.setAutoScroll(true);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}