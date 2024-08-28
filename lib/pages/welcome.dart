import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:work_zone/widgets/colors.dart';

import 'signin.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: offWhite,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'lib/assets/img/logo/logo-light.svg',
              height: MediaQuery.sizeOf(context).height/7,
              width: MediaQuery.sizeOf(context).width/2,
            ),
            SizedBox(height: 60),
            GestureDetector(
              onTap: () {
                Get.to(() => SignInScreen());
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                decoration: BoxDecoration(
                    color: lime300,
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    )),
                child: Text(
                  "LET'S GO",
                  style: TextStyle(
                    color: offWhite,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
