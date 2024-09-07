import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:work_zone/pages/buyer/buyer_home.dart';
import 'package:work_zone/pages/buyer/buyer_job_list.dart';
import 'package:work_zone/pages/buyer/buyer_order.dart';
import 'package:work_zone/pages/buyer/buyer_profile.dart';
import 'package:work_zone/widgets/colors.dart';

class CustomBottomNavigationBarBuyer extends StatelessWidget {
  final int currentIndex;
  final Color selectedItemColor;
  final Color unselectedItemColor;

  const CustomBottomNavigationBarBuyer({
    super.key,
    required this.currentIndex,
    this.selectedItemColor = primary,
    this.unselectedItemColor = dark200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
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
          // Use Get.off() for better navigation
          switch (index) {
            case 0:
              Get.off(() => BuyerHome());
              break;
            case 1:
            // Handle message navigation
              break;
            case 2:
              Get.off(() => BuyerJobList());
              break;
            case 3:
              Get.off(() => const BuyerOrder());
              break;
            case 4:
              Get.off(() => const BuyerProfile());
              break;
          }
        },
      ),
    );
  }
}
