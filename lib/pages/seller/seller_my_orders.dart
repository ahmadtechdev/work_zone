import 'package:flutter/material.dart';

class SellerMyOrders extends StatefulWidget {
  @override
  _SellerMyOrdersState createState() => _SellerMyOrdersState();
}

class _SellerMyOrdersState extends State<SellerMyOrders> {
  final List<Map<String, dynamic>> dummyOrders = [
    {
      'image': 'lib/assets/img/others/1.png',
      'title': 'Professional Laravel Development & API Integration',
      'amount': 30000.00,
      'status': 'Declined',
      'buyer': 'Moaze',
      'deliveryDate': '28 August 2024',
    },{
      'image': 'lib/assets/img/others/1.png',
      'title': 'Professional Laravel Development & API Integration',
      'amount': 30000.00,
      'status': 'Declined',
      'buyer': 'Moaze',
      'deliveryDate': '28 August 2024',
    },{
      'image': 'lib/assets/img/others/1.png',
      'title': 'Professional Laravel Development & API Integration',
      'amount': 30000.00,
      'status': 'Declined',
      'buyer': 'Moaze',
      'deliveryDate': '28 August 2024',
    },
    // Add more dummy orders as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Handle create new gig action
            },
            child: Text('Create a New Gig'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: dummyOrders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(dummyOrders[index]);
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    order['image'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['title'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Pkr ${order['amount'].toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem('Status', order['status'], _getStatusColor(order['status'])),
                _buildInfoItem('Buyer', order['buyer'], Colors.black87),
              ],
            ),
            SizedBox(height: 8),
            _buildInfoItem('Expected Delivery', order['deliveryDate'], Colors.black87),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.email, color: Colors.blue),
                  onPressed: () {
                    // Handle email action
                  },
                ),
                IconButton(
                  icon: Icon(Icons.visibility, color: Colors.green),
                  onPressed: () {
                    // Handle view action
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'declined':
        return Colors.red;
      case 'delivered':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }
}