import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:work_zone/widgets/bottom_navigation_bar_seller.dart';
import 'package:work_zone/widgets/colors.dart';
import '../../service/api_service.dart';
import 'seller_submit_order.dart';

class SellerOrder extends StatefulWidget {
  const SellerOrder({super.key});

  @override
  State<SellerOrder> createState() => _SellerOrderState();
}

class _SellerOrderState extends State<SellerOrder> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> tabs = ['Accepted', 'Pending', 'Delivered','Make A Revision','Completed', 'Declined'];
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
      final orders = await apiService.getSellerOrders();
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
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<OrderCard> getOrdersByStatus(String status) {
    return allOrders
        .where((order) => order['status'] == status)
        .map((order) => OrderCard(
      orderId: order['id'].toString(),
      orderDate: DateTime.parse(order['created_at']),
      duration: Duration(days: int.parse(order['delivery_time'].split(' ')[0])),
      buyer: order['buyer_name'],
      title: order['gig_title'],
      amount: double.parse(order['price']),
      status: order['status'],
      image: order['gig_img'] ?? "https://cdn-icons-png.flaticon.com/128/13434/13434972.png",
      onOrderStatusChanged: fetchOrders,
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
        title: const Text('Orders'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: tabs.map((String tab) => Tab(text: tab)).toList(),
            isScrollable: true,
            labelColor: primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: primary,
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
      bottomNavigationBar: const CustomBottomNavigationBarSeller(currentIndex: 3),
    );
  }
}

class OrderCard extends StatefulWidget {
  final String orderId;
  final DateTime orderDate;
  final Duration duration;
  final String buyer;
  final String title;
  final double amount;
  final String status;
  final String image;
  final VoidCallback onOrderStatusChanged;

  const OrderCard({
    super.key,
    required this.orderId,
    required this.orderDate,
    required this.duration,
    required this.buyer,
    required this.title,
    required this.amount,
    required this.status,
    required this.image,
    required this.onOrderStatusChanged,
  });

  @override
  _OrderCardState createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  late Timer _timer;
  late int _remainingSeconds;
  final ApiService apiService = ApiService();

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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _timer.cancel();
          }
        });
      }
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
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order ID #${widget.orderId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: List.generate(4, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        timeUnits[index],
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Buyer: ${widget.buyer} | ${widget.orderDate.toString().split(' ')[0]}'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOrderDetail('Gig Title', widget.title),
                      _buildOrderDetail('Duration', '${widget.duration.inDays} Days'),
                      _buildOrderDetail('Amount', 'R.s ${widget.amount.toStringAsFixed(2)}'),
                      _buildOrderDetail('Status', widget.status),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  child: Image.network(
                    widget.image,
                    height: 90,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (widget.status == 'Accepted' || widget.status == 'Make A Revision')
              Center(
                child: ElevatedButton(
                  onPressed: () => Get.to(() => const SellerSubmitOrder(), arguments: {
                    "order_id" : widget.orderId,
                  }),
                  style: ElevatedButton.styleFrom(backgroundColor: blue300),
                  child: const Text('Submit Order', style: TextStyle(color: Colors.white)),
                ),
              ),

            if (widget.status == 'Pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () => _handleOrderAction(true),
                    style: ElevatedButton.styleFrom(backgroundColor: primary),
                    child: const Text('Accept Order', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () => _handleOrderAction(false),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Decline Order', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleOrderAction(bool isAccepting) async {
    try {
      if (isAccepting) {
        await apiService.acceptOrder(widget.orderId);
      } else {
        await apiService.declineOrder(widget.orderId);
      }
      widget.onOrderStatusChanged();
    } catch (e) {
      print('Error ${isAccepting ? 'accepting' : 'declining'} order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to ${isAccepting ? 'accept' : 'decline'} order')),
      );
    }
  }

  Widget _buildOrderDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text('$label :', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}