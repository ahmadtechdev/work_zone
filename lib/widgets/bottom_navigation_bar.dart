import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:work_zone/pages/buyer/buyer_home.dart';
import 'package:work_zone/pages/buyer/buyer_job_list.dart';
import 'package:work_zone/pages/buyer/buyer_order.dart';
import 'package:work_zone/pages/buyer/buyer_profile.dart';
import 'package:work_zone/widgets/colors.dart'; // Import the Get package

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Color selectedItemColor;
  final Color unselectedItemColor;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    this.selectedItemColor = lime300,
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
          icon: Icon(Icons.work),
          label: 'Job Apply',
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
          Get.to(() => BuyerHome());
        } else if (index == 1) {
          // Get.to(() => BuyerHome());
        } else if (index == 2) {
          Get.to(() => JobPostPage());
        }else if (index == 3) {
          Get.to(() => const BuyerOrder());
        }else if (index == 4) {
          Get.to(() => const BuyerProfile());
        }
      },
    );
  }
}
