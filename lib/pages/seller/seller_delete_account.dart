// buyer_delete_account.dart

import 'package:flutter/material.dart';
import 'package:work_zone/widgets/colors.dart';

import 'package:get/get.dart';
import 'package:work_zone/pages/signin.dart';

import '../../service/api_service.dart';

class SellerDeleteAccount extends StatefulWidget {
  const SellerDeleteAccount({super.key});

  @override
  State<SellerDeleteAccount> createState() => _SellerDeleteAccountState();
}

class _SellerDeleteAccountState extends State<SellerDeleteAccount> {
  final ApiService apiService = ApiService();

  Future<void> _deleteAccount() async {
    try {
      final response = await apiService.deleteAccount();
      if (response['success'] == true) {
        // Account deleted successfully
        Get.offAll(() => SignInScreen());
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to delete account'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            margin: const EdgeInsets.only(bottom: 12, right: 20, left: 20),
          ),
        );
      }
      Get.offAll(() => SignInScreen());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          margin: const EdgeInsets.only(bottom: 12, right: 20, left: 20),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Account Delete'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              "https://cdn-icons-png.flaticon.com/128/9790/9790368.png",
              height: 150,
              width: 150,
            ),
            const SizedBox(height: 20),
            const Text(
              'Notice: Remember you will not be able to login this account after deleting your account.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _deleteAccount,
                  child: const Text('Yes Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child:
                  const Text('Cancel', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
