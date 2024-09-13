import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_zone/service/api_service.dart';
import 'package:work_zone/widgets/colors.dart';
import 'package:shimmer/shimmer.dart'; // Add shimmer package for skeleton loader

class BuyerDashboard extends StatefulWidget {
  const BuyerDashboard({Key? key}) : super(key: key);

  @override
  _BuyerDashboardState createState() => _BuyerDashboardState();
}

class _BuyerDashboardState extends State<BuyerDashboard> {
  final ApiService apiService = ApiService();
  bool isLoading = true;
  Map<String, dynamic> dashboardData = {};
  List<dynamic> jobs = [];

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      setState(() => isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('dashboardData');

      if (cachedData != null) {
        dashboardData = Map<String, dynamic>.from(jsonDecode(cachedData));
        jobs = dashboardData['jobs'] ?? [];
      } else {
        final response = await apiService.get('buyer-dashboard');
        dashboardData = response;
        jobs = dashboardData['jobs'] ?? [];
        prefs.setString('dashboardData', jsonEncode(dashboardData));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load dashboard data: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return primary;
      case 'pending':
        return secondary;
      case 'in progress':
        return Colors.blue;
      default:
        return Colors.green;
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
        title: const Text('Dashboard'),
      ),
      body: isLoading
          ? buildSkeletonLoader()
          : RefreshIndicator(
        onRefresh: fetchDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    buildDashboardCard(
                      icon: Icons.account_balance_wallet,
                      iconColor: Colors.green,
                      title: '${dashboardData['user_balance'] ?? 0}',
                      subtitle: 'Current balance',
                    ),
                    buildDashboardCard(
                      icon: Icons.shopping_cart,
                      iconColor: Colors.blue,
                      title: '${dashboardData['jobscount'] ?? 0}',
                      subtitle: 'Total Jobs',
                    ),
                    buildDashboardCard(
                      icon: Icons.check_circle,
                      iconColor: Colors.purple,
                      title: '${dashboardData['orders_completed'] ?? 0}',
                      subtitle: 'Complete Orders',
                    ),
                    buildDashboardCard(
                      icon: Icons.pending_actions,
                      iconColor: Colors.cyan,
                      title: '${dashboardData['orders_active'] ?? 0}',
                      subtitle: 'Active Orders',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Latest Jobs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return buildJobCard(job);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSkeletonLoader() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        buildSkeletonCard(),
        buildSkeletonCard(),
        buildSkeletonCard(),
        buildSkeletonCard(),
      ],
    );
  }

  Widget buildSkeletonCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                color: Colors.grey,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDashboardCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: iconColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildJobCard(Map<String, dynamic> job) {
    final imageUrl = job['gig_img'] != null
        ? '${apiService.baseUrlImg}${job['gig_img']}'
        : 'https://cdn-icons-png.flaticon.com/128/13434/13434972.png';
    final statusColor = getStatusColor(job['status'] ?? 'Unknown');

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: Icon(Icons.image, color: Colors.grey[400]),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job['title'] ?? 'No Title',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Category: ${job['category'] ?? 'N/A'}",
                    style: TextStyle(color: dark400.withOpacity(0.6), fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Budget: ${job['budget'] ?? 0} - ${job['maxbudget'] ?? 0}",
                    style: TextStyle(color: dark400.withOpacity(0.6), fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Duration: ${job['jobDuration'] ?? 'N/A'}',
                    style: TextStyle(color: dark400.withOpacity(0.6), fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Status: ${job['status'] ?? 'No Status'}',
                    style: TextStyle(color: statusColor, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
