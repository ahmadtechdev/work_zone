import 'dart:async';

import 'package:flutter/material.dart';
import 'package:work_zone/widgets/bottom_navigation_bar_seller.dart';

class SellerOrder extends StatefulWidget {
  const SellerOrder({super.key});

  @override
  State<SellerOrder> createState() => _SellerOrderState();
}

class _SellerOrderState  extends State<SellerOrder> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> tabs = ['Active', 'Pending', 'Completed', 'Cancelled'];

  // Sample order data - in a real app, this would come from an API or database
  final List<OrderCard> allOrders = [
    OrderCard(
      orderId: 'F025E15',
      orderDate: DateTime(2024, 8, 17),
      duration: Duration(days: 3),
      seller: 'Shaidul Islam',
      title: 'Mobile UI UX design or app UI UX design',
      amount: 5.00,
      status: 'Active',
    ),
    OrderCard(
      orderId: 'F025E16',
      orderDate: DateTime(2024, 8, 17),
      duration: Duration(days: 2),
      seller: 'John Doe',
      title: 'Web Development Project',
      amount: 10.00,
      status: 'Pending',
    ),

    OrderCard(
      orderId: 'F025E18',
      orderDate: DateTime(2024, 8, 17),
      duration: Duration(days: 4),
      seller: 'Bob Johnson',
      title: 'Content Writing',
      amount: 7.00,
      status: 'Cancelled',
    ),
    OrderCard(
      orderId: 'F025E18',
      orderDate: DateTime(2024, 8, 17),
      duration: Duration(days: 4),
      seller: 'Bob Johnson',
      title: 'Content Writing',
      amount: 7.00,
      status: 'Active',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<OrderCard> getOrdersByStatus(String status) {
    return allOrders.where((order) => order.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Orders'),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: tabs.map((String tab) => Tab(text: tab)).toList(),
            isScrollable: true,
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.green,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: tabs.map((String tab) {
                List<OrderCard> filteredOrders = getOrdersByStatus(tab);
                return filteredOrders.isEmpty
                    ? Center(child: Text('No $tab orders'))
                    : ListView(children: filteredOrders);
              }).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBarSeller(currentIndex: 3),
    );
  }
}

class OrderCard extends StatefulWidget {
  final String orderId;
  final DateTime orderDate;
  final Duration duration;
  final String seller;
  final String title;
  final double amount;
  final String status;

  const OrderCard({
    Key? key,
    required this.orderId,
    required this.orderDate,
    required this.duration,
    required this.seller,
    required this.title,
    required this.amount,
    required this.status,
  }) : super(key: key);

  @override
  _OrderCardState createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  late Timer _timer;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _calculateRemainingTime() {
    DateTime endTime = widget.orderDate.add(widget.duration);
    Duration remaining = endTime.difference(DateTime.now());
    _remainingSeconds = remaining.inSeconds > 0 ? remaining.inSeconds : 0;
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer.cancel();
        }
      });
    });
  }

  String formatTime(int seconds) {
    int days = seconds ~/ 86400;
    int hours = (seconds % 86400) ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$days:${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    List<String> timeUnits = formatTime(_remainingSeconds).split(':');

    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order ID #${widget.orderId}', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: List.generate(4, (index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        timeUnits[index],
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Seller: ${widget.seller} | ${widget.orderDate.toString().split(' ')[0]}'),
            SizedBox(height: 8),
            _buildOrderDetail('Title', widget.title),
            _buildOrderDetail('Duration', '${widget.duration.inDays} Days'),
            _buildOrderDetail('Amount', '\$ ${widget.amount.toStringAsFixed(2)}'),
            _buildOrderDetail('Status', widget.status),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text('$label :', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}