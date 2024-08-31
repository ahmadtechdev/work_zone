import 'package:flutter/material.dart';
import 'package:work_zone/widgets/colors.dart';
import '../../service/api_service.dart';

class SellerWithdrawRequest extends StatefulWidget {
  @override
  _SellerWithdrawRequestState createState() => _SellerWithdrawRequestState();
}

class _SellerWithdrawRequestState extends State<SellerWithdrawRequest> {
  final _formKey = GlobalKey<FormState>();
  final _bankWalletController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _accountNoController = TextEditingController();
  final _amountController = TextEditingController();
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Withdraw Now'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: 24),
              Text(
                'Withdraw Your Balance Now',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              _buildTransferDetails(),
              SizedBox(height: 24),
              _buildForm(),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdownField('Bank/Wallet Name', _bankWalletController),
          SizedBox(height: 16),
          _buildTextField('Account Name', _accountNameController),
          SizedBox(height: 16),
          _buildTextField('Account No', _accountNoController),
          SizedBox(height: 16),
          _buildTextField('Amount', _amountController),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitWithdrawRequest,
              child: Text('Submit Withdraw Request'),
              style: ElevatedButton.styleFrom(
                backgroundColor: lime300,
                foregroundColor: white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, TextEditingController controller) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: <String>['Select Bank or Wallet', 'Bank A', 'Bank B', 'Wallet X', 'Wallet Y']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          controller.text = newValue!;
        });
      },
      validator: (value) {
        if (value == null || value == 'Select Bank or Wallet') {
          return 'Please select a bank or wallet';
        }
        return null;
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildTransferDetails() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transfer Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'Please ensure that all the necessary details are filled in correctly before proceeding with the withdrawal. Double-check your account name, account number, and the amount to avoid any delays in processing your request.',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _submitWithdrawRequest() async {
    if (_formKey.currentState!.validate()) {
      // Here you would typically call your API service to submit the withdrawal request
      // For now, we'll just show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Withdrawal request submitted successfully'),
          backgroundColor: lime300,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          margin: const EdgeInsets.only(bottom: 12, right: 20, left: 20),
        ),
      );
    }
  }

  @override
  void dispose() {
    _bankWalletController.dispose();
    _accountNameController.dispose();
    _accountNoController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}