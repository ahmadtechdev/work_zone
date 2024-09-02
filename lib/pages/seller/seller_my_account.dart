import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';
import 'package:work_zone/pages/seller/seller_withdraw_request.dart';
import 'package:work_zone/widgets/colors.dart';

import '../../service/api_service.dart';



class SellerMyAccount extends StatefulWidget {
  const SellerMyAccount({Key? key}) : super(key: key);

  @override
  State<SellerMyAccount> createState() => _SellerMyAccountState();
}

class _SellerMyAccountState extends State<SellerMyAccount> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic> userData = {};
  List<dynamic> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSellerAccountData();
  }

  Future<void> _fetchSellerAccountData() async {
    try {
      final response = await _apiService.getSellerAccount(); // Assuming the endpoint is same as buyer
      setState(() {
        userData = response['user'];
        transactions = response['withdraws'];
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching seller account data: $e');
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
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Balance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${userData['balance']?.toString() ?? '0.00'}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Handle withdraw action
                    Get.to(() => SellerWithdrawRequest());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  icon: Icon(Icons.arrow_forward, size: 18, color: white,),
                  label: Text('Withdraw', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Ensure you have sufficient balance before making a withdrawal.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
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

    return Column(
      children: [
        SizedBox(height: 8,),
        Expanded(
          child: ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return _buildTransactionRow(transaction);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionHeader() {
    return Container(
      color: Colors.green.withOpacity(0.3),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Bank Name', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Account No', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Account Name', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Dated', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(Map<String, dynamic> transaction) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Account No: ${transaction['account_no'] ?? 'N/A'}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
                Chip(
                  label: Text(
                    transaction['status'] ?? 'Unknown',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: (transaction['status'] ?? '').toLowerCase() == 'pending'
                      ? Colors.redAccent
                      : Colors.green,
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Name:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(transaction['account_name'] ?? 'N/A'),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${transaction['amount']?.toString() ?? '0.00'}',
                      style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                DateFormat('yyyy-MM-dd HH:mm:ss').format(
                  DateTime.parse(transaction['created_at'] ?? DateTime.now().toIso8601String()),
                ),
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

}