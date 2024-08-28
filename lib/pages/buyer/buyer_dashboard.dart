import 'package:flutter/material.dart';

class BuyerDashboard extends StatelessWidget {
  const BuyerDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Dashboard'),
      ),
      body: SingleChildScrollView(
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
                physics: NeverScrollableScrollPhysics(),
                children: [
                  DashboardCard(
                    icon: Icons.account_balance_wallet,
                    iconColor: Colors.green,
                    title: '\$4000.0',
                    subtitle: 'Current Balance',
                  ),
                  DashboardCard(
                    icon: Icons.account_balance,
                    iconColor: Colors.orange,
                    title: '\$5000.0',
                    subtitle: 'Total Deposited',
                  ),
                  DashboardCard(
                    icon: Icons.swap_horiz,
                    iconColor: Colors.red,
                    title: '\$4000.0',
                    subtitle: 'Total Transactions',
                  ),
                  DashboardCard(
                    icon: Icons.shopping_cart,
                    iconColor: Colors.blue,
                    title: '10',
                    subtitle: 'Total Order',
                  ),
                  DashboardCard(
                    icon: Icons.check_circle,
                    iconColor: Colors.purple,
                    title: '08',
                    subtitle: 'Completed Order',
                  ),
                  DashboardCard(
                    icon: Icons.pending_actions,
                    iconColor: Colors.cyan,
                    title: '02',
                    subtitle: 'Incompleted Order',
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text(
                'Latest Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTransactionRow('Seller', 'Seller'),
                      _buildTransactionRow('Date', '24 Jun 2023'),
                      _buildTransactionRow('Amount', '\$3000.0'),
                      _buildTransactionRow('Status', 'Paid'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: iconColor),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}