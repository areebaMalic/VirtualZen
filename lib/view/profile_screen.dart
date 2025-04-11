import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewModel/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
/*
    final userProvider = Provider.of<UserProvider>(context);
*/

    // Handle null user
    /*if (userProvider.user == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Profile")),
        body: Center(child: CircularProgressIndicator()), // Show loader until data is available
      );
    }*/

/*
    final user = userProvider.user!;
*/

    return Scaffold(
      body: Center(
        child: Text("user Profile"),
      )
      
     /* Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: user.profilePicture.isNotEmpty
                ? NetworkImage(user.profilePicture)
                : AssetImage('assets/default_avatar.png') as ImageProvider,
          ),
          SizedBox(height: 10),
          Text(user.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text("@${user.username}", style: TextStyle(color: Colors.grey)),
          Text("Joined: ${user.joinDate.toLocal()}"),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${user.followers} Followers"),
              SizedBox(width: 10),
              Text("${user.following} Following"),
            ],
          ),
        ],
      ),*/
    );
  }
}
