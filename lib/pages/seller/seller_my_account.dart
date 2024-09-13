import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart'; // For skeleton loading
import 'package:work_zone/service/api_service.dart';
import 'package:work_zone/widgets/colors.dart';

import 'seller_withdraw_request.dart';

class SellerMyAccount extends StatefulWidget {
  const SellerMyAccount({Key? key}) : super(key: key);

  @override
  State<SellerMyAccount> createState() => _SellerMyAccountState();
}

class _SellerMyAccountState extends State<SellerMyAccount> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  Map<String, dynamic> userData = {};
  List<dynamic> transactions = [];
  bool isLoading = true;
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _fetchSellerAccountData();
  }

  Future<void> _fetchSellerAccountData() async {
    setState(() {
      isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('sellerAccountData');
      if (cachedData != null && !isRefreshing) {
        setState(() {
          final parsedData = jsonDecode(cachedData);
          userData = parsedData['user'];
          transactions = parsedData['withdraws'];
          isLoading = false;
        });
      } else {
        final response = await _apiService.get('my-account');
        setState(() {
          userData = response['user'];
          transactions = response['withdraws'];
          isLoading = false;
        });
        prefs.setString('sellerAccountData', jsonEncode(response));
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching seller account data: $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isRefreshing = true;
    });
    await _fetchSellerAccountData();
    setState(() {
      isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: isLoading ? _buildSkeletonLoader() : _buildContent(),
    );
  }

  Widget _buildSkeletonLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView(
        children: List.generate(5, (index) => _buildSkeletonCard()),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Column(
        children: [
          _buildBalanceCard(),
          const SizedBox(height: 16),
          _buildTransactionList(),
        ],
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
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${userData['balance']?.toString() ?? '0.00'}',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.green[700]),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.to(() => SellerWithdrawRequest());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text('Withdraw', style: TextStyle( color: white),),
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
      return const Expanded(child: Center(child: Text('No transactions available')));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return _buildTransactionRow(transaction);
        },
      ),
    );
  }

  Widget _buildTransactionRow(Map<String, dynamic> transaction) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(AnimationController(vsync: this, duration: const Duration(seconds: 1))),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction['bank_name'] ?? 'Unknown',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Account No: ${transaction['account_no'] ?? 'N/A'}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  Chip(
                    label: Text(
                      transaction['status'] ?? 'Unknown',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: (transaction['status'] ?? '').toLowerCase() == 'pending'
                        ? Colors.redAccent
                        : Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Account Name: ${transaction['account_name'] ?? 'N/A'}'),
                  Text(
                    'Amount: ${transaction['amount']?.toString() ?? '0.00'}',
                    style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(
                    DateTime.parse(transaction['created_at'] ?? DateTime.now().toIso8601String()),
                  ),
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
