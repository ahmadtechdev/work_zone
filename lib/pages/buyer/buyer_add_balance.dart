import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:work_zone/pages/buyer/buyer_my_account.dart';
import 'package:work_zone/widgets/colors.dart';

import '../../service/api_service.dart';


class BuyerAddBalance extends StatefulWidget {
  const BuyerAddBalance({Key? key}) : super(key: key);

  @override
  _BuyerAddBalanceState createState() => _BuyerAddBalanceState();
}

class _BuyerAddBalanceState extends State<BuyerAddBalance> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  String _senderName = '';
  String _transactionId = '';
  double _amount = 0.0;
  Map<String, dynamic> _bankDetails = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTransactionDetails();
  }

  Future<void> _fetchTransactionDetails() async {
    try {
      final response = await _apiService.getTransactionDetails();
      setState(() {
        _bankDetails = response['bankdetails'];
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching transaction details: $e');
      setState(() {
        _isLoading = false;
      });
      // TODO: Show error message to user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Balance'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Balance in your account',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildTransferDetailsCard(),
            SizedBox(height: 24),
            _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferDetailsCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transfer Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildDetailRow('Account Holder:', _bankDetails['account_holder'] ?? 'N/A'),
            _buildDetailRow('Account Number:', _bankDetails['account_number'] ?? 'N/A'),
            _buildDetailRow('Account Type:', _bankDetails['account_type'] ?? 'N/A'),
            SizedBox(height: 8),
            Text(
              'Please send the specified amount to this account and ensure that you accurately fill in all the necessary details.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Sender Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter sender name';
              }
              return null;
            },
            onSaved: (value) => _senderName = value!,
          ),
          SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Transaction ID',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter transaction ID';
              }
              return null;
            },
            onSaved: (value) => _transactionId = value!,
          ),
          SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(),
              hintText: '',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter amount';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
            onSaved: (value) => _amount = double.parse(value!),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitForm,
            child: Text('Add Money'),
            style: ElevatedButton.styleFrom(
              backgroundColor: lime300,
              foregroundColor: white,
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final response = await _apiService.storeBalance(_senderName, _transactionId, _amount);
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'])),
          );
          Get.off(()=> BuyerMyAccount());
        } else {
          throw Exception(response['message']);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}