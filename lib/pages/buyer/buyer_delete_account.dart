import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_zone/pages/signin.dart';
import 'package:work_zone/service/api_service.dart';
import 'package:work_zone/widgets/colors.dart';

import '../../widgets/snackbar.dart';

class BuyerDeleteAccount extends StatefulWidget {
  const BuyerDeleteAccount({super.key});

  @override
  State<BuyerDeleteAccount> createState() => _BuyerDeleteAccountState();
}

class _BuyerDeleteAccountState extends State<BuyerDeleteAccount>
    with SingleTickerProviderStateMixin {
  final ApiService apiService = ApiService();
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward(); // Start the animation
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the animation controller
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await apiService.deleteAccount();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      CustomSnackBar(
        message: response['message'] ?? 'Account deleted successfully!',
        backgroundColor: Colors.green,
      ).show(context);
      Get.offAll(() => SignInScreen());
      // if (response['success'] == true) {
      //   // Account deleted successfully
      //   // Navigate to SignInScreen
      // } else {
      //   // Show error message
      //   CustomSnackBar(
      //     message: response['message'] ?? 'Failed to delete account',
      //     backgroundColor: Colors.green,
      //   ).show(context);
      //
      // }
    } catch (e) {
      CustomSnackBar(
        message: 'An error occurred: $e',
        backgroundColor: Colors.red,
      ).show(context);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoading() : _buildDeleteAccountContent(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('Delete Account'),
      backgroundColor: primary.withOpacity(0.2),
      elevation: 0,
    );
  }

  Widget _buildDeleteAccountContent() {
    return FadeTransition(
      opacity: _animation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replace Image.network with a local asset or a better image if needed
            Image.network(
              "https://cdn-icons-png.flaticon.com/128/9790/9790368.png",
              height: 150,
              width: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            const Text(
              'Notice: Once your account is deleted, you will lose access to it permanently.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: dark200,
              ),
            ),
            const SizedBox(height: 30),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _deleteAccount,
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            'Yes, Delete',
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent.withOpacity(0.7),
            foregroundColor: white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: primary),
    );
  }
}