import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart'; // Add shimmer package for skeleton loader
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../service/api_service.dart';
import '../../widgets/colors.dart';
import 'buyer_add_balance.dart';

class BuyerMyAccount extends StatefulWidget {
  const BuyerMyAccount({Key? key}) : super(key: key);

  @override
  _BuyerMyAccountState createState() => _BuyerMyAccountState();
}

class _BuyerMyAccountState extends State<BuyerMyAccount> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic> userData = {};
  List<dynamic> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBuyerAccountData();
  }

  Future<void> _fetchBuyerAccountData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('buyer-account');

    if (cachedData != null) {
      setState(() {
        final data = jsonDecode(cachedData);
        userData = data['user'];
        transactions = data['transactions'];
        isLoading = false;
      });
    } else {
      try {
        final response = await _apiService.get('buyer-account');
        setState(() {
          userData = response['user'];
          transactions = response['transactions'];
          isLoading = false;
        });
        await prefs.setString('buyerAccountData', jsonEncode(response));
      } catch (e) {
        print('Error fetching buyer account data: $e');
        setState(() {
          isLoading = false;
        });
        // TODO: Handle error (e.g., show error message to user)
      }
    }
  }

  Future<void> _refreshData() async {
    await _fetchBuyerAccountData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Account'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: isLoading
          ? _buildSkeletonLoader()
          : RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildBalanceCard(),
            SizedBox(height: 16),
            _buildTransactionList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 120,
                    height: 24,
                    color: Colors.grey,
                  ),
                  Container(
                    width: 100,
                    height: 36,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            children: List.generate(3, (index) => _buildSkeletonTransactionCard()),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonTransactionCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 16,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 16,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Container(
              width: 100,
              height: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Balance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${userData['balance']?.toString() ?? '0.00'}',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green[700]),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.to(() => BuyerAddBalance());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text('Add Balance'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    if (transactions.isEmpty) {
      return Center(child: Text('No transactions available', style: TextStyle(fontSize: 16, color: Colors.grey)));
    }

    return Column(
      children: transactions.map((transaction) => _buildTransactionCard(transaction)).toList(),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final statusColor = (transaction['status'] ?? '').toLowerCase() == 'pending'
        ? Colors.red.withOpacity(0.6)
        : Colors.green;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction['sender_name'] ?? 'Unknown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Till ID: ${transaction['tid'] ?? 'N/A'}',
              style: TextStyle(fontSize: 16, color: dark200),
            ),
            Text(
              'Amount: ${transaction['amount']?.toString() ?? '0.00'}',
              style: TextStyle(fontSize: 16, color: dark300),
            ),
            Text(
              'Date & time: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(transaction['created_at'] ?? DateTime.now().toIso8601String()))}',
              style: TextStyle(fontSize: 16, color: dark200),
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Chip(
                label: Text(
                  transaction['status'] ?? 'Unknown',
                  style: TextStyle(color: white),
                ),
                backgroundColor: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
