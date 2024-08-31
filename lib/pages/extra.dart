import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:work_zone/pages/seller/seller_create_gig.dart';

import '../../widgets/bottom_navigation_bar_seller.dart';

class SellerManageGig extends StatefulWidget {
  @override
  _SellerManageGigState createState() => _SellerManageGigState();
}

class _SellerManageGigState extends State<SellerManageGig> {
  final List<Map<String, dynamic>> dummyGigs = [
    {
      'image': 'lib/assets/img/others/1.png',
      'price': 30000.00,
      'rating': 4.8,
      'ratingCount': 2000,
      'title': 'Professional Laravel Development & API Integration',
      'sellerName': 'Moaze seller',
    },
    {
      'image': 'lib/assets/img/others/1.png',
      'price': 25000.00,
      'rating': 4.5,
      'ratingCount': 1500,
      'title': 'Full Stack Web Development with React and Node.js',
      'sellerName': 'John Doe',
    },
    // Add more dummy gigs as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Manage Gig'),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Handle create new gig action
              Get.to(()=> SellerCreateGig());
            },
            child: Text('Create a new Gig'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: dummyGigs.length,
        itemBuilder: (context, index) {
          return _buildGigCard(dummyGigs[index]);
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBarSeller(currentIndex: 2),
    )
    ;
  }

  Widget _buildGigCard(Map<String, dynamic> gig) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
            child: Image.asset(
              gig['image'],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pkr ${gig['price'].toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        Text(
                          '${gig['rating']} (${gig['ratingCount']})',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  gig['title'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage('https://example.com/avatar.jpg'),
                      radius: 12,
                    ),
                    SizedBox(width: 8),
                    Text(
                      gig['sellerName'],
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Handle edit gig action
                      },
                      child: Text('Edit Gig'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Handle delete gig action
                      },
                      child: Text('Delete Gig'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}