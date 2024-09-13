import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_zone/pages/buyer/buyer_home.dart';
import 'package:work_zone/pages/seller/seller_home.dart';
import 'package:work_zone/pages/signup.dart';
import 'package:work_zone/widgets/colors.dart';
import '../service/api_service.dart';
import '../widgets/button.dart';
import '../widgets/snackbar.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final ApiService apiService = ApiService();
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color) {
    final snackBar = CustomSnackBar(message: message, backgroundColor: color);
    snackBar.show(context);
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      var body = {
        'email': loginEmailController.text.trim(),
        'password': loginPasswordController.text.trim(),
      };

      try {
        final response = await apiService.post('login', body);

        if (response['success'] == true) {
          await _handleLoginSuccess(response);
        } else {
          _showSnackBar('Login failed: ${response['message'] ?? "Unknown error"}', Colors.red);
        }
      } catch (e) {

        _showSnackBar('An error occurred: $e', Colors.red);
        print(e);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLoginSuccess(Map<String, dynamic> response) async {
    var userData = response['data']['user'];
    var token = response['data']['token'];
    var role = userData['role'];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('role', role);



    if (role == "seller") {
      Get.offAll(() => SellerDashboard(), arguments: userData);
    } else if (role == "buyer") {
      Get.offAll(() => BuyerHome(), arguments: userData);
    } else {
      _showSnackBar('Undefined Role!', Colors.red);
    }
  }

  InputDecoration _buildInputDecoration(String labelText) {
    return InputDecoration(
      fillColor: offWhite,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      labelText: labelText,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        // backgroundColor: offWhite,
        title: const Text(
          "Sign In",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              height: 300.0,
              child: SvgPicture.asset(
                'lib/assets/img/logo/logo-light.svg',
                height: MediaQuery.sizeOf(context).height / 7,
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: loginEmailController,
                    decoration: _buildInputDecoration('Email'),
                    validator: (value) => value!.isEmpty || !value.contains('@') ? 'Enter valid Email' : null,
                  ),
                  const SizedBox(height: 10.0),
                  TextFormField(
                    controller: loginPasswordController,
                    obscureText: _obscurePassword,
                    decoration: _buildInputDecoration('Password').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) => value!.isEmpty ? 'Enter password' : null,
                  ),
                  const SizedBox(height: 30.0),
                ],
              ),
            ),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RoundButton(title: "Sign in", onTap: _login),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.to(() => BuyerHome());
                  },
                  child: const Text("Don't have an account? "),
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => const SignUp());
                  },
                  child: Card(
                    color: primary,
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        "Create Account",
                        style: TextStyle(color: offWhite, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



}
