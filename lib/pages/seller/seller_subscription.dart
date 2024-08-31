import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'seller_withdraw_request.dart';

class SellerSubscriptions extends StatefulWidget {
  @override
  _SellerSubscriptionsState createState() => _SellerSubscriptionsState();
}

class _SellerSubscriptionsState extends State<SellerSubscriptions> {
  final double currentBalance = 0.00;
  final List<Map<String, dynamic>> subscriptions = [
    {
      'planType': 'Easypaisa',
      'price': '030000000',
      'paymentGateway': 'Moaz',
      'paymentStatus': '100',
      'status': 'Pending',
      'expireDate': '2024-08-29 10:32:22',
    },
    {
      'planType': 'UBL',
      'price': '030000000',
      'paymentGateway': 'Moaz',
      'paymentStatus': '189000.00',
      'status': 'Pending',
      'expireDate': '2024-08-29 10:37:06',
    },
    // Add more subscriptions as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Account'),

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: 8),
              _buildBalanceSection(),
              SizedBox(height: 24),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: subscriptions.length,
                itemBuilder: (context, index) {
                  return _buildSubscriptionCard(subscriptions[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Current Balance: ${currentBalance.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // Handle withdraw action
            Get.to(()=> SellerWithdrawRequest());
          },
          child: Text('Withdraw Now'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard(Map<String, dynamic> subscription) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subscription['planType'],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn('Price', subscription['price']),
                _buildInfoColumn('Payment Gateway', subscription['paymentGateway']),
                _buildInfoColumn('Payment Status', subscription['paymentStatus']),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusChip(subscription['status']),
                Text(
                  'Expire Date: ${subscription['expireDate']}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    return Chip(
      label: Text(
        status,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: status.toLowerCase() == 'pending' ? Colors.orange : Colors.green,
    );
  }
}