import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:virtual_zen/utils/constant.dart';
import 'package:virtual_zen/view/community_screen.dart';
import 'package:virtual_zen/view/feed_screen.dart';
import 'package:virtual_zen/view/flying_hscreen.dart';
import 'package:virtual_zen/view/height_hscreen.dart';
import 'package:virtual_zen/view/profile_screen.dart';
import 'package:virtual_zen/view/spider_Hscreen.dart';
import 'package:virtual_zen/viewModel/page_view_model.dart';
import 'package:virtual_zen/viewModel/profile_view_model.dart';
import '../service/notification_services.dart';
import '../viewModel/friend_requests_view_model.dart';
import '../viewModel/friends_view_model.dart';

class BottomBarScreen extends StatefulWidget {
  const BottomBarScreen({super.key});

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    NotificationServices notificationServices = NotificationServices();
    notificationServices.requestNotificationPermission();

    Future.microtask(() {
      if (!_initialized) {
        final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
        final pageViewModel = Provider.of<PageViewModel>(context, listen: false);
        final friendVM = Provider.of<FriendsViewModel>(context, listen: false);

        profileViewModel.tryLoadProfileWithRetry(); // loads profile
        Future.delayed(Duration.zero, () {
          final friendReqVM = Provider.of<FriendRequestViewModel>(context, listen: false);
          friendReqVM.listenForRequests();
        });
        friendVM.initialize();
         pageViewModel.loadPhobia(); // loads phobia from shared prefs
        _initialized = true;
      }
    });
  }


  Widget getPhobiaScreen(String? phobia) {
    switch (phobia) {
      case "flying":
        return FlyingHomePage();
      case "spider":
        return SpidersHomePage();
      case "height":
        return HeightsHomePage();
      default:
        return const Center(child: Text("No phobia selected"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProfileViewModel, PageViewModel>(
      builder: (context, profileVM, navigationProvider, _) {
        // Show loading until both are ready
        if (profileVM.isLoadingProfile || navigationProvider.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final List<Widget> pages = [
          getPhobiaScreen(navigationProvider.selectedPhobia),
          Feed(),
          CommunityScreen(),
          ProfileScreen(),
        ];

        return Scaffold(
          backgroundColor: Colors.white,
          body: PageView(
            controller: navigationProvider.pageController,
            onPageChanged: navigationProvider.setCurrentIndex,
            children: pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: navigationProvider.currentIndex,
            onTap: navigationProvider.setCurrentIndex,
            selectedItemColor: kFilledButtonColor,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Phobia"),
              BottomNavigationBarItem(icon: Icon(Icons.music_note), label: "Meditation"),
              BottomNavigationBarItem(icon: Icon(Icons.people), label: "Community"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
            ],
          ),
        );
      },
    );
  }
}
