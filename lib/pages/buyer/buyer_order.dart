import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:work_zone/widgets/bottom_navigation_bar_buyer.dart';
import 'package:work_zone/widgets/colors.dart';
import 'package:shimmer/shimmer.dart';

import '../../service/api_service.dart';

class BuyerOrder extends StatefulWidget {
  const BuyerOrder({Key? key}) : super(key: key);

  @override
  State<BuyerOrder> createState() => _BuyerOrderState();
}

class _BuyerOrderState extends State<BuyerOrder> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> tabs = ['Active', 'Pending', 'Completed', 'Cancelled'];
  List<Map<String, dynamic>> allOrders = [];
  bool isLoading = true;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final orders = await apiService.getBuyerOrders();
      if (mounted) {
        setState(() {
          allOrders = orders;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching orders: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<OrderCard> getOrdersByStatus(String status) {
    // var image =  apiService.baseUrlImg + order['gig_img'];
    return allOrders
        .where((order) => order['status'] == status)
        .map((order) => OrderCard(
      orderId: order['id'].toString(),
      orderDate: DateTime.parse(order['created_at']),
      duration: Duration(days: int.parse(order['delivery_time'].split(' ')[0])),
      seller: order['seller_name'],
      title: order['gig_title'],
      amount: double.parse(order['price']),
      status: order['status'],

      image: (order['gig_img'] != null && order['gig_img'].isNotEmpty)
          ? apiService.baseUrlImg + order['gig_img']
          : "http://10.10.0.100:500/gigs/1726647309.png",

    ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Orders'),
        backgroundColor: primary,
      ),
      body: Column(
        children: [
          AnimatedBuilder(
            animation: _tabController.animation!,
            builder: (context, child) {
              return Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  tabs: tabs.map((String tab) => Tab(text: tab)).toList(),
                  labelColor: primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: primary,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
                ),
              );
            },
          ),
          Expanded(
            child: isLoading
                ? OrdersSkeleton()
                : TabBarView(
              controller: _tabController,
              children: tabs.map((String tab) {
                List<OrderCard> filteredOrders = getOrdersByStatus(tab);
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: filteredOrders.isEmpty
                      ? Center(child: Text('No $tab orders'))
                      : ListView.builder(
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      return AnimatedOpacity(
                        duration: Duration(milliseconds: 300),
                        opacity: 1,
                        child: filteredOrders[index],
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBarBuyer(currentIndex: 3),
    );
  }
}

class OrderCard extends StatelessWidget {
  final String orderId;
  final DateTime orderDate;
  final Duration duration;
  final String seller;
  final String title;
  final double amount;
  final String status;
  final String image;

  const OrderCard({
    Key? key,
    required this.orderId,
    required this.orderDate,
    required this.duration,
    required this.seller,
    required this.title,
    required this.amount,
    required this.status,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order #$orderId', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                _buildStatusChip(status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    image,
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('Seller: $seller', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('Due: ${DateFormat('MMM dd, yyyy').format(orderDate.add(duration))}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rs. ${amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, color: primary, fontSize: 16)),
                OutlinedButton(
                  onPressed: () {
                    // TODO: Implement order details navigation
                  },
                  child: const Text('View Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: BorderSide(color: primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'active':
        chipColor = Colors.green;
        break;
      case 'pending':
        chipColor = Colors.orange;
        break;
      case 'completed':
        chipColor = Colors.blue;
        break;
      case 'cancelled':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }
}

class OrdersSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 24,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 100,
                              height: 12,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 80,
                        height: 20,
                        color: Colors.white,
                      ),
                      Container(
                        width: 100,
                        height: 30,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}