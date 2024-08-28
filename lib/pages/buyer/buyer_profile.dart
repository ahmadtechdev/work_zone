import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:work_zone/pages/buyer/buyer_change_password.dart';
import 'package:work_zone/pages/buyer/buyer_dashboard.dart';
import 'package:work_zone/pages/buyer/buyer_delete_account.dart';
import 'package:work_zone/pages/buyer/buyer_my_account.dart';
import 'package:work_zone/pages/buyer/buyer_my_profile.dart';
import 'package:work_zone/widgets/bottom_navigation_bar.dart';
import '../../service/api_service.dart';
import '../signin.dart';

class BuyerProfile extends StatefulWidget {
  const BuyerProfile({super.key});

  @override
  State<BuyerProfile> createState() => _BuyerProfileState();
}

class _BuyerProfileState extends State<BuyerProfile> {
  @override
  Widget build(BuildContext context) {
    final ApiService apiService = ApiService();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Profile'),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              children: [
                _buildListItem(Icons.person, 'My Profile', Colors.green,() {
                  Get.to(()=> BuyerMyProfile());
                }),
                _buildListItem(
                    Icons.dashboard, 'Dashboard', Colors.blue, () {
                      Get.to(()=>BuyerDashboard());
                }),
                _buildListItem(
                    Icons.account_balance_wallet, 'My Account', Colors.orange,() {
                    Get.to(()=> BuyerMyAccount());
                }),
                _buildListItem(Icons.swap_horiz, 'Transaction', Colors.red,() {}),
                _buildListItem(Icons.favorite, 'Favorite', Colors.purple,() {}),
                _buildListItem(
                    Icons.assessment, 'Seller Report', Colors.lightBlue,() {}),
                _buildListItem(Icons.settings, 'Setting', Colors.pink,() {}),
                _buildListItem(
                    Icons.person_add, 'Change Password', Colors.green,() {
                  Get.to(()=>BuyerUpdatePassword());
                }),
                _buildListItem(Icons.no_accounts, 'Delete Account', Colors.red,() {
                  Get.to(()=>BuyerDeleteAccount());
                }),
                _buildListItem(Icons.exit_to_app, 'Log Out', Colors.orange,() async {

                  try {
                    final response = await apiService.logoutAccount();
                    if (response['success'] == true) {
                      // Account deleted successfully
                      Get.offAll(() => SignInScreen());
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(response['message'] ?? 'logout successfully '),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          margin: const EdgeInsets.only(bottom: 12, right: 20, left: 20),
                        ),
                      );
                    } else {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(response['message'] ?? 'Failed to logout account'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          margin: const EdgeInsets.only(bottom: 12, right: 20, left: 20),
                        ),
                      );
                    }
                    // Get.offAll(() => SignInScreen());
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
                }),
              ],
            ),
          ),
          // _buildBottomNavBar(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 4),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage:
                AssetImage('lib/assets/img/others/1.png'), // Add your image
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
                'Deposit Balance: \$ 500.00',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(
      IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
