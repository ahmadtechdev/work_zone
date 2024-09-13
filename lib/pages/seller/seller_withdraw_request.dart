import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:work_zone/pages/seller/seller_my_account.dart';
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
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Withdraw Now'),
        backgroundColor: primary.withOpacity(0.2),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 24),
              Text(
                'Withdraw Your Balance',
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

  Widget _buildTransferDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
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

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdownField('Bank/Wallet Name', _bankWalletController),
          SizedBox(height: 16),
          _buildTextField('Account Name', _accountNameController, false),
          SizedBox(height: 16),
          _buildTextField('Account No', _accountNoController, true),
          SizedBox(height: 16),
          _buildTextField('Amount', _amountController, true),
          SizedBox(height: 24),
          _isLoading ? _buildLoaderButton() : _buildSubmitButton(),
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
      items: [
        DropdownMenuItem(value: '', child: Text('Select Bank or Wallet')),
        DropdownMenuItem(value: 'HBL', child: Text('Habib Bank Limited (HBL)')),
        DropdownMenuItem(
            value: 'UBL', child: Text('United Bank Limited (UBL)')),
        DropdownMenuItem(value: 'MCB', child: Text('Muslim Commercial Bank (MCB)')),
        DropdownMenuItem(value: 'Allied Bank', child: Text('Allied Bank')),
        DropdownMenuItem(value: 'Bank Alfalah', child: Text('Bank Alfalah')),
        DropdownMenuItem(value: 'Standard Chartered', child: Text('Standard Chartered')),
        DropdownMenuItem(value: 'Meezan Bank', child: Text('Meezan Bank')),
        DropdownMenuItem(value: 'Askari Bank', child: Text('Askari Bank')),
        DropdownMenuItem(value: 'National Bank of Pakistan', child: Text('National Bank of Pakistan (NBP)')),
        DropdownMenuItem(value: 'Faysal Bank', child: Text('Faysal Bank')),

        // Add other bank/wallet options...
        DropdownMenuItem(value: 'JazzCash', child: Text('JazzCash')),
        DropdownMenuItem(value: 'Easypaisa', child: Text('Easypaisa')),
        DropdownMenuItem(value: 'UPaisa', child: Text('UPaisa')),
        DropdownMenuItem(value: 'SadaPay', child: Text('SadaPay')),
        DropdownMenuItem(value: 'NayaPay', child: Text('NayaPay')),
      ],
      onChanged: (String? newValue) {
        controller.text = newValue ?? '';
      },
      validator: (value) {
        if (value == null || value.isEmpty || value == '') {
          return 'Please select a bank or wallet';
        }
        return null;
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isNumber) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text, // Set keyboard type based on isNumber
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


  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitWithdrawRequest,
        child: Text('Submit Withdraw Request'),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildLoaderButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: null,
        child: CircularProgressIndicator(
          color: white,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  void _submitWithdrawRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _apiService.post(
          "store-withdraw",
          {
            "bank_name": _bankWalletController.text,
            "account_name": _accountNameController.text,
            "account_no": _accountNoController.text,
            "amount": _amountController.text,
          },
        );

        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Withdrawal request submitted successfully'),
              backgroundColor: primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              margin: const EdgeInsets.only(bottom: 12, right: 20, left: 20),
            ),
          );
          Get.to(() => SellerMyAccount());
        } else {
          throw Exception(response['message']);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            margin: const EdgeInsets.only(bottom: 12, right: 20, left: 20),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
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
