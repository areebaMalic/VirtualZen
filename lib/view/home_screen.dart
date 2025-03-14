import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virtual_zen/utils/routes/route_name.dart';
import 'package:virtual_zen/viewModel/auth_view_model.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Consumer<AuthViewModel>(
          builder: (context, authViewModel, child) {
            return TextButton(
              onPressed: () async {
                await authViewModel.logoutUser();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pushNamed(context, RouteName.login);
              },
              child: Text('Logout', style: TextStyle(color: Colors.black87, fontSize: 23)),
            );
          },
        )

      ),
      body: const Center(
          child: Text('HomePage',style:
          TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey
          ),)
      ),
    );
  }
}