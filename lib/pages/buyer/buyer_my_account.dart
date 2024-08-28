import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../service/api_service.dart';
import '../../widgets/colors.dart';
import 'buyer_add_balance.dart';

class BuyerMyAccount extends StatefulWidget {
  const BuyerMyAccount({Key? key}) : super(key: key);

  @override
  State<BuyerMyAccount> createState() => _BuyerMyAccountState();
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
    try {
      final response = await _apiService.getBuyerAccount();
      setState(() {
        userData = response['user'];
        transactions = response['transactions'];
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching buyer account data: $e');
      setState(() {
        isLoading = false;
      });
      // TODO: Handle error (e.g., show error message to user)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Account'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildBalanceCard(),
          SizedBox(height: 16),
          Expanded(
            child: _buildTransactionList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Balance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${userData['balance'].toString() ?? '0.00'}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.to(() => BuyerAddBalance());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lime300,
                    foregroundColor: white,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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
      return Center(child: Text('No transactions available'));
    }
    print(transactions);

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(transaction['sender_name'] ?? 'Unknown'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Till ID: ${transaction['tid'] ?? 'N/A'}'),
                Text('Amount: ${(transaction['amount'] ?? 0.0).toString()}'),
                Text('Date: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(transaction['created_at'] ?? DateTime.now().toIso8601String()))}'),
              ],
            ),
            trailing: Chip(
              label: Text(
                transaction['status'] ?? 'Unknown',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: (transaction['status'] ?? '').toLowerCase() == 'pending' ? Colors.red.withOpacity(0.6) : Colors.green,
            ),
          ),
        );
      },
    );
  }
}