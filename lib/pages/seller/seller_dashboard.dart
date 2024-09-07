import 'package:flutter/material.dart';
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
      final response = await apiService.get('seller-dashboard');
      setState(() {
        dashboardData = response;
        jobs = dashboardData['jobs'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load dashboard data: $e')),
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
        title: const Text('Dashboard'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
                    DashboardCard(
                      icon: Icons.account_balance_wallet,
                      iconColor: Colors.green,
                      title: '${dashboardData['user_balance'] ?? 0}',
                      subtitle: 'Current balance',
                    ),
                    DashboardCard(
                      icon: Icons.shopping_cart,
                      iconColor: Colors.blue,
                      title: '${dashboardData['proposals'] ?? 0}',
                      subtitle: 'Proposals Sent',
                    ),
                    DashboardCard(
                      icon: Icons.check_circle,
                      iconColor: Colors.purple,
                      title: '${dashboardData['orders_completed'] ?? 0}',
                      subtitle: 'Complete Orders',
                    ),
                    DashboardCard(
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
                    return JobCard(job: job, apiService: apiService);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const DashboardCard({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}

class JobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final ApiService apiService;

  const JobCard({Key? key, required this.job, required this.apiService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = job['gig_img'] != null
        ? '${apiService.baseUrlImg}${job['gig_img']}'
        : 'https://cdn-icons-png.flaticon.com/128/13434/13434972.png';

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
                    style: TextStyle(color: primary, fontSize: 14),
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