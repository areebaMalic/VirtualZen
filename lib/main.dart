import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:virtual_zen/utils/routes/route_name.dart';
import 'package:virtual_zen/utils/routes/routes.dart';
import 'package:virtual_zen/viewModel/auth_view_model.dart';
import 'package:virtual_zen/viewModel/page_view_model.dart';
import 'package:virtual_zen/viewModel/phobia_view_model.dart';
import 'package:virtual_zen/viewModel/user_provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent
        )
    );

    return ScreenUtilInit(
      builder: (context, child) {
        return  MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => PageViewModel()),
              ChangeNotifierProvider(create: (_) => AuthViewModel()),
              ChangeNotifierProvider(create: (_) => PhobiaViewModel()),
              ChangeNotifierProvider(create: (_) => UserProvider()),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Flutter Demo',
              theme: ThemeData(),
              initialRoute: RouteName.splash,
              onGenerateRoute: Routes.generateRoute,
            )
        );
      },
      designSize: const Size(375, 812),
    );
  }
}