import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_zone/pages/welcome.dart';
import 'package:work_zone/widgets/colors.dart';

import 'pages/buyer/buyer_home.dart';
import 'pages/seller/seller_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  Widget initialScreen;

  if (token != null && token.isNotEmpty) {
    // Check user role (assuming you saved it in SharedPreferences as well)
    String role = prefs.getString('role') ?? '';
    if (role == 'seller') {
      initialScreen = const SellerDashboard();
    } else if (role == 'buyer') {
      initialScreen = BuyerHome();
    } else {
      initialScreen = WelcomeScreen(); // Fallback in case of an undefined role
    }
  } else {
    initialScreen = WelcomeScreen();
  }

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'WorkZone',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        useMaterial3: true,
      ),
      home: initialScreen,
    );
  }
}
