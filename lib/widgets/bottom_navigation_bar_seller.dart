import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:work_zone/pages/seller/seller_home.dart';
import 'package:work_zone/pages/seller/seller_order.dart';
import 'package:work_zone/widgets/colors.dart';

import '../pages/seller/seller_manage_gig.dart';
import '../pages/seller/seller_profile.dart'; // Import the Get package

class CustomBottomNavigationBarSeller extends StatelessWidget {
  final int currentIndex;
  final Color selectedItemColor;
  final Color unselectedItemColor;

  const CustomBottomNavigationBarSeller({
    super.key,
    required this.currentIndex,
    this.selectedItemColor = primary,
    this.unselectedItemColor = dark200,// Default color if not provided
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.message,
          ),
          label: 'Message',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_card),
          label: 'Service',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.request_page),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      showUnselectedLabels: true,

      onTap: (int index) {
        if (index == 0) {
          Get.to(() => SellerDashboard());
        } else if (index == 1) {
          // Get.to(() => BuyerHome());
        } else if (index == 2) {
          Get.to(() => SellerManageGig());
        }else if (index == 3) {
          Get.to(() => const SellerOrder());
        }else if (index == 4) {
          Get.to(() => const SellerProfile());
        }
      },
    );
  }
}
