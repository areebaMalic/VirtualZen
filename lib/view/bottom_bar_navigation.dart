import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virtual_zen/utils/constant.dart';
import 'package:virtual_zen/view/spider_Hscreen.dart';
import 'package:virtual_zen/view/height_hscreen.dart';
import 'package:virtual_zen/view/flying_hscreen.dart';
import '../utils/routes/route_name.dart';
import '../view/community_screen.dart';
import '../view/profile_screen.dart';
import '../viewModel/page_view_model.dart';
import 'feed_screen.dart';

class BottomBarScreen extends StatefulWidget {
  @override
  _BottomBarScreenState createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  String selectedPhobia = "height";

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPhobia = prefs.getString('selectedPhobia');
    int? savedIndex = prefs.getInt('lastSelectedIndex');

    setState(() {
      selectedPhobia = savedPhobia ?? "height";
    });

    final pageViewModel = Provider.of<PageViewModel>(context, listen: false);
    pageViewModel.setCurrentNavigationIndex(savedIndex ?? 0);
    pageViewModel.pageController.jumpToPage(savedIndex ?? 0);
  }

  Future<void> _logoutUser(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('lastSelectedIndex');
    Navigator.pushReplacementNamed(context, RouteName.login);
  }

  Widget getPhobiaScreen() {
    switch (selectedPhobia) {
      case "flying":
        return FlyingHomePage();
      case "spider":
        return SpidersHomePage();
      default:
        return HeightsHomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<PageViewModel>(context);

    final List<Widget> pages = [
      getPhobiaScreen(),                  // Phobia screen (dynamic)
      Feed(),           // Relaxation screen
      CommunityScreen(),                 // Community screen
      ProfileScreen(),                   // Profile screen
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kFilledButtonColor,
        title: const Text("VirtualZen", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logoutUser(context),
          ),
        ],
      ),
      body: PageView(
        controller: navigationProvider.pageController,
        onPageChanged: (index) async {
          navigationProvider.onPageChanged(index);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('lastSelectedIndex', index);
        },
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationProvider.currentIndex,
        onTap: (index) async {
          navigationProvider.setCurrentIndex(index);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('lastSelectedIndex', index);
        },
        selectedItemColor: kFilledButtonColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Phobia"),
          BottomNavigationBarItem(icon: Icon(Icons.music_note), label: "Relaxation"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Community"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
