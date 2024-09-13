import 'package:flutter/material.dart';

import 'package:work_zone/widgets/colors.dart';

import '../../service/api_service.dart';
import '../../widgets/snackbar.dart';

class BuyerUpdatePassword extends StatefulWidget {
  @override
  _BuyerUpdatePasswordState createState() => _BuyerUpdatePasswordState();
}

class _BuyerUpdatePasswordState extends State<BuyerUpdatePassword> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoading() : _buildPasswordForm(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Update Password'),
      backgroundColor: primary.withOpacity(0.2), // Lighter, eye-pleasing color
      elevation: 0,
    );
  }

  Widget _buildPasswordForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const Text(
              'Update your password below. Required fields are marked *',
              style: TextStyle(fontSize: 12, color: dark200),
            ),
            const SizedBox(height: 20),
            _buildPasswordField(
              controller: _currentPasswordController,
              label: 'Current Password *',
              obscureText: _obscureCurrentPassword,
              togglePasswordVisibility: () {
                setState(() {
                  _obscureCurrentPassword = !_obscureCurrentPassword;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your current password';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _newPasswordController,
              label: 'New Password *',
              obscureText: _obscureNewPassword,
              togglePasswordVisibility: () {
                setState(() {
                  _obscureNewPassword = !_obscureNewPassword;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a new password';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: 'Confirm Password *',
              obscureText: _obscureConfirmPassword,
              togglePasswordVisibility: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your new password';
                }
                if (value != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            _buildUpdatePasswordButton(),
            const SizedBox(height: 10),
            _buildCancelButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required Function() togglePasswordVisibility,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: togglePasswordVisibility,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildUpdatePasswordButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _updatePassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Update Password',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Cancel', style: TextStyle(color: Colors.red)),
      ),
    );
  }

  Future<void> _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading animation
      });

      try {
        final response = await _apiService.post('user-update-password', {
          'current_password': _currentPasswordController.text,
          'new_password': _newPasswordController.text,
          'new_password_confirmation': _confirmPasswordController.text,
        });

        if (response['status'] == 'success') {
          CustomSnackBar(
            message: response['message'] ?? 'Password updated successfully!',
            backgroundColor: Colors.green,
          ).show(context);
          Navigator.of(context).pop(); // Go back after successful update
        } else {
          CustomSnackBar(
            message: response['message'] ?? 'Password update failed!',
            backgroundColor: Colors.red,
          ).show(context);
        }
      } catch (e) {
        CustomSnackBar(
          message: 'An error occurred: $e',
          backgroundColor: Colors.red,
        ).show(context);
      } finally {
        setState(() {
          _isLoading = false; // Hide loading animation
        });
      }
    }
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: primary),
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}