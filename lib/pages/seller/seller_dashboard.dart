import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart'; // For skeleton loading effect
import 'package:work_zone/service/api_service.dart';
import 'package:work_zone/widgets/colors.dart';

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({Key? key}) : super(key: key);

  @override
  _SellerDashboardState createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
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
      final cachedData = prefs.getString('sellerDashboardData');

      if (cachedData != null) {
        setState(() {
          dashboardData = jsonDecode(cachedData);
          jobs = dashboardData['jobs'] ?? [];
          isLoading = false;
        });
      } else {
        await _fetchDataFromApi();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load dashboard data: $e')),
      );
    }
  }

  Future<void> _fetchDataFromApi() async {
    try {
      final response = await apiService.get('seller-dashboard');
      setState(() {
        dashboardData = response;
        jobs = dashboardData['jobs'] ?? [];
        isLoading = false;
      });
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('sellerDashboardData', jsonEncode(dashboardData));
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data from API: $e')),
      );
    }
  }

  Future<void> refreshDashboard() async {
    await _fetchDataFromApi();
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
        title: const Text('Seller Dashboard'),
      ),
      body: isLoading
          ? buildSkeletonLoader()
          : RefreshIndicator(
        onRefresh: refreshDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildDashboardGrid(), // GridView for the cards
                const SizedBox(height: 24),
                const Text(
                  'Latest Jobs',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                buildJobList(), // ListView for the jobs
              ],
            ),
          ),
        ),
      ),
    );
  }

  // This method builds the dashboard grid
  Widget buildDashboardGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true, // Important to shrink the grid
      physics: const NeverScrollableScrollPhysics(), // Disable scrolling inside GridView
      children: [
        buildDashboardCard(
          icon: Icons.account_balance_wallet_rounded,
          iconColor: Colors.green,
          title: '${dashboardData['user_balance'] ?? 0}',
          subtitle: 'Current Balance',
        ),
        buildDashboardCard(
          icon: Icons.assignment_turned_in_rounded,
          iconColor: Colors.blue,
          title: '${dashboardData['proposals'] ?? 0}',
          subtitle: 'Proposals Sent',
        ),
        buildDashboardCard(
          icon: Icons.check_circle_rounded,
          iconColor: Colors.purple,
          title: '${dashboardData['orders_completed'] ?? 0}',
          subtitle: 'Complete Orders',
        ),
        buildDashboardCard(
          icon: Icons.pending_rounded,
          iconColor: Colors.cyan,
          title: '${dashboardData['orders_active'] ?? 0}',
          subtitle: 'Active Orders',
        ),
      ],
    );
  }

  // This method builds each dashboard card
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

  // This method builds the list of job cards
  Widget buildJobList() {
    return ListView.builder(
      shrinkWrap: true, // Shrink the ListView to fit its content
      physics: const NeverScrollableScrollPhysics(), // Disable scrolling inside ListView
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return buildJobCard(job);
      },
    );
  }

  // This method builds each job card
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
                    "Budget: \$${job['budget'] ?? 0} - \$${job['maxbudget'] ?? 0}",
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

  // This method builds the skeleton loader
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

  // This method builds each skeleton card
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
}