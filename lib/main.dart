import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:work_zone/pages/signin.dart';
import 'package:work_zone/pages/starter1.dart';
import 'package:work_zone/pages/welcome.dart';
import 'package:work_zone/widgets/colors.dart';

import 'pages/buyer/buyer_home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(

      title: 'WorkZone',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: lime300),
        useMaterial3: true,
      ),
      home: WelcomeScreen(),
    );
  }
}

