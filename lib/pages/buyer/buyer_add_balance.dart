import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:work_zone/pages/buyer/buyer_my_account.dart';
import 'package:work_zone/widgets/colors.dart';
import 'dart:convert';

import '../../service/api_service.dart';
import '../../widgets/snackbar.dart'; // Assuming CustomSnackBar is defined here

class BuyerAddBalance extends StatefulWidget {
  const BuyerAddBalance({super.key});

  @override
  _BuyerAddBalanceState createState() => _BuyerAddBalanceState();
}

class _BuyerAddBalanceState extends State<BuyerAddBalance>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  String _senderName = '';
  String _transactionId = '';
  double _amount = 0.0;
  Map<String, dynamic> _bankDetails = {};
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchTransactionDetails();
  }

  Future<void> _fetchTransactionDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('transactionDetails');
      if (cachedData != null) {
        setState(() {
          _bankDetails = jsonDecode(cachedData);
          _isLoading = false;
        });
      } else {
        await _refreshTransactionDetails();
      }
    } catch (e) {
      print('Error fetching transaction details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshTransactionDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _apiService.get('transaction-details');
      setState(() {
        _bankDetails = response['bankdetails'];
        _isLoading = false;
      });

      // Cache the data
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('transactionDetails', jsonEncode(_bankDetails));
    } catch (e) {
      print('Error refreshing transaction details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Balance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTransactionDetails,
          ),
        ],
      ),
      body: _isLoading
          ? _buildSkeletonLoader()
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Balance to Your Account',
              style: TextStyle(
                fontSize: 18, // Adjusted font size
                fontWeight: FontWeight.bold,
                color: secondary, // Using primary color for the heading
              ),
            ),
            const SizedBox(height: 16),
            _buildTransferDetailsCard(),
            const SizedBox(height: 24),
            _buildFormExplanation(), // Explanation heading above the form
            const SizedBox(height: 12),
            _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 200,
                  height: 24,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                _buildSkeletonCard(),
                const SizedBox(height: 24),
                _buildSkeletonForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      width: double.infinity,
      height: 150,
      color: Colors.white,
    );
  }

  Widget _buildSkeletonForm() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 50,
          color: Colors.white,
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 50,
          color: Colors.white,
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 50,
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildTransferDetailsCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transfer Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: dark400),
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Account Holder:', _bankDetails['account_holder'] ?? 'N/A'),
            _buildDetailRow('Account Number:', _bankDetails['account_number'] ?? 'N/A'),
            _buildDetailRow('Account Type:', _bankDetails['account_type'] ?? 'N/A'),
            const SizedBox(height: 8),
            const Text(
              'Please transfer the specified amount to this account and ensure that all details are accurately recorded.',
              style: TextStyle(fontStyle: FontStyle.italic, color: dark200),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormExplanation() {
    return const Text(
      'After transferring the amount, please fill in the transaction details below.',
      style: TextStyle(
        fontSize: 14,
        color: dark200,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: dark200)),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(color: dark300)),
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
            decoration: const InputDecoration(
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
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Transaction ID',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number, // Only allow numbers
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter transaction ID';
              }
              return null;
            },
            onSaved: (value) => _transactionId = value!,
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Only numbers allowed
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
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitForm,
            child: _isSubmitting
                ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(white),
            )
                : const Text('Add Money'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: white,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSubmitting = true;
      });
      try {
        final response = await _apiService.post(
          'store-balance',
          {
            'sender_name': _senderName,
            'tid': _transactionId,
            'amount': _amount,
          },
        );
        if (response['status'] == 'success') {
          CustomSnackBar(
            message: response['message'],
            backgroundColor: Colors.green,
          ).show(context);
          Get.off(() => const BuyerMyAccount());
        } else {
          throw Exception(response['message']);
        }
      } catch (e) {
        CustomSnackBar(
          message: 'Error: ${e.toString()}',
          backgroundColor: Colors.red,
        ).show(context);
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}