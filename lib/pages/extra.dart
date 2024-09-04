// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:work_zone/widgets/bottom_navigation_bar_seller.dart';
// import 'package:work_zone/widgets/colors.dart';
//
// import '../../service/api_service.dart';
// // Import the API service
//
// class SellerOrder extends StatefulWidget {
//   const SellerOrder({super.key});
//
//   @override
//   State<SellerOrder> createState() => _SellerOrderState();
// }
//
// class _SellerOrderState extends State<SellerOrder> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   List<String> tabs = ['Active', 'Pending', 'Completed', 'Cancelled'];
//   List<Map<String, dynamic>> allOrders = [];
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: tabs.length, vsync: this);
//     fetchOrders();
//   }
//
//   Future<void> fetchOrders() async {
//     try {
//       final apiService = ApiService();
//       final orders = await apiService.getSellerOrders();
//       setState(() {
//         allOrders = orders;
//         isLoading = false;
//       });
//     } catch (e) {
//       print('Error fetching orders: $e');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   List<OrderCard> getOrdersByStatus(String status) {
//     return allOrders
//         .where((order) => order['status'] == status)
//         .map((order) => OrderCard(
//       orderId: order['id'].toString(),
//       orderDate: DateTime.parse(order['created_at']),
//       duration: Duration(days: int.parse(order['delivery_time'].split(' ')[0])),
//       seller: 'Seller Name', // You might need to fetch this from user data
//       title: order['description'],
//       amount: double.parse(order['price']),
//       status: order['status'],
//     ))
//         .toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text('Orders'),
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Column(
//         children: [
//           TabBar(
//             controller: _tabController,
//             tabs: tabs.map((String tab) => Tab(text: tab)).toList(),
//             isScrollable: true,
//             labelColor: lime300,
//             unselectedLabelColor: Colors.grey,
//             indicatorColor: lime300,
//           ),
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: tabs.map((String tab) {
//                 List<OrderCard> filteredOrders = getOrdersByStatus(tab);
//                 return filteredOrders.isEmpty
//                     ? Center(child: Text('No $tab orders'))
//                     : ListView(children: filteredOrders);
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: CustomBottomNavigationBarSeller(currentIndex: 3),
//     );
//   }
// }
//
//
// class OrderCard extends StatefulWidget {
//   final String orderId;
//   final DateTime orderDate;
//   final Duration duration;
//   final String seller;
//   final String title;
//   final double amount;
//   final String status;
//
//   const OrderCard({
//     Key? key,
//     required this.orderId,
//     required this.orderDate,
//     required this.duration,
//     required this.seller,
//     required this.title,
//     required this.amount,
//     required this.status,
//   }) : super(key: key);
//
//   @override
//   _OrderCardState createState() => _OrderCardState();
// }
//
// class _OrderCardState extends State<OrderCard> {
//   late Timer _timer;
//   late int _remainingSeconds;
//
//   @override
//   void initState() {
//     super.initState();
//     _calculateRemainingTime();
//     startTimer();
//   }
//
//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }
//
//   void _calculateRemainingTime() {
//     DateTime endTime = widget.orderDate.add(widget.duration);
//     Duration remaining = endTime.difference(DateTime.now());
//     _remainingSeconds = remaining.inSeconds > 0 ? remaining.inSeconds : 0;
//   }
//
//   void startTimer() {
//     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
//       setState(() {
//         if (_remainingSeconds > 0) {
//           _remainingSeconds--;
//         } else {
//           _timer.cancel();
//         }
//       });
//     });
//   }
//
//   String formatTime(int seconds) {
//     int days = seconds ~/ 86400;
//     int hours = (seconds % 86400) ~/ 3600;
//     int minutes = (seconds % 3600) ~/ 60;
//     int remainingSeconds = seconds % 60;
//     return '$days:${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     List<String> timeUnits = formatTime(_remainingSeconds).split(':');
//
//     return Card(
//       margin: EdgeInsets.all(8),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Order ID #${widget.orderId}', style: TextStyle(fontWeight: FontWeight.bold)),
//                 Row(
//                   children: List.generate(4, (index) {
//                     return Container(
//                       margin: EdgeInsets.symmetric(horizontal: 2),
//                       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.green,
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(
//                         timeUnits[index],
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     );
//                   }),
//                 ),
//               ],
//             ),
//             SizedBox(height: 8),
//             Text('Seller: ${widget.seller} | ${widget.orderDate.toString().split(' ')[0]}'),
//             SizedBox(height: 8),
//             _buildOrderDetail('Title', widget.title),
//             _buildOrderDetail('Duration', '${widget.duration.inDays} Days'),
//             _buildOrderDetail('Amount', '\$ ${widget.amount.toStringAsFixed(2)}'),
//             _buildOrderDetail('Status', widget.status),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOrderDetail(String label, String value) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(width: 80, child: Text('$label :', style: TextStyle(fontWeight: FontWeight.bold))),
//           Expanded(child: Text(value)),
//         ],
//       ),
//     );
//   }
// }