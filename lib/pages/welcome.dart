import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:work_zone/widgets/colors.dart';
import 'signin.dart';

class WelcomeScreen extends StatelessWidget {
  final double logoHeightFactor = 7;
  final double logoWidthFactor = 2;
  final double buttonPaddingVertical = 15;
  final double buttonPaddingHorizontal = 40;
  final double buttonFontSize = 22;
  final double verticalSpacing = 60;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // color: offWhite,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'lib/assets/img/logo/logo-light.svg',
              height: screenHeight / logoHeightFactor,
              width: screenWidth / logoWidthFactor,
            ),
            SizedBox(height: verticalSpacing),

            // Animated button with a subtle scale animation
            GestureDetector(
              onTap: () {
                Get.to(() => SignInScreen());
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(
                  vertical: buttonPaddingVertical,
                  horizontal: buttonPaddingHorizontal,
                ),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  "LET'S GO",
                  style: TextStyle(
                    color: offWhite,
                    fontSize: buttonFontSize,
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
