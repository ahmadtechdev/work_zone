import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:work_zone/pages/seller/seller_dashboard.dart';
import 'package:work_zone/widgets/bottom_navigation_bar_buyer.dart';
import 'package:work_zone/widgets/bottom_navigation_bar_seller.dart';
// Assuming this is the updated CustomSnackBar
import '../../widgets/colors.dart'; // Custom color palette
import '../../service/api_service.dart';
import '../../widgets/snackbar.dart';
import '../signin.dart';
import 'seller_change_password.dart';
import 'seller_delete_account.dart';
import 'seller_my_account.dart';

class SellerProfile extends StatefulWidget {
  const SellerProfile({super.key});

  @override
  State<SellerProfile> createState() => _SellerProfileState();
}

class _SellerProfileState extends State<SellerProfile> {
  final ApiService apiService = ApiService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading ? _buildSkeletonLoader() : _buildProfileContent(),
      bottomNavigationBar: CustomBottomNavigationBarSeller(currentIndex: 4),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('Menu'),
      elevation: 0,
      backgroundColor: offWhite, // Lighter background color for the AppBar
      foregroundColor: dark300, // Darker text/icon color for contrast
    );
  }

  Widget _buildProfileContent() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: ListView(
            children: [
              _buildListItem(Icons.person, 'My Profile', Colors.purple, () {
                // Get.to(() => BuyerMyProfile());
              }),
              _buildListItem(Icons.dashboard, 'Dashboard', Colors.lightBlue, () {
                Get.to(() => SellerDashboard());
              }),
              _buildListItem(Icons.account_balance_wallet, 'My Account', Colors.orange, () {
                Get.to(() => SellerMyAccount());
              }),
              _buildListItem(Icons.lock, 'Change Password', Colors.green, () {
                Get.to(() => SellerUpdatePassword());
              }),
              _buildListItem(Icons.delete, 'Delete Account', Colors.red, () {
                Get.to(() => const SellerDeleteAccount());
              }),
              _buildListItem(Icons.logout, 'Log Out', Colors.pink, () => _logout(context)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: primary.withOpacity(0.1),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('lib/assets/img/others/1.png'),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Shahidul Islam',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Current Balance: \$500.00',
                style: TextStyle(fontSize: 14, color: dark200),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Future<void> _logout(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await apiService.post('logout', {});
      if (response['success'] == true) {
        // Clear all data from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear(); // Clear all stored preferences including the token

        // Log out and navigate to SignInScreen
        Get.offAll(() => SignInScreen());
        CustomSnackBar(
          message: response['message'] ?? 'Logout successful',
          backgroundColor: Colors.green,
        ).show(context);
      } else {
        // Logout failed
        CustomSnackBar(
          message: response['message'] ?? 'Logout failed',
          backgroundColor: Colors.red,
        ).show(context);
      }
    } catch (e) {
      // Handle errors
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

  Widget _buildSkeletonLoader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 50,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 50,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 50,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}