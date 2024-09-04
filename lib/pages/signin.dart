import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_zone/pages/buyer/buyer_home.dart';
import 'package:work_zone/pages/seller/seller_home.dart';
import 'package:work_zone/pages/signup.dart';// Import the API service
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
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    loginEmailController.dispose();
    loginPasswordController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    CustomSnackBar(message: 'check',backgroundColor: Colors.red,);
  }
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      var loginEmail = loginEmailController.text.trim();
      var loginPassword = loginPasswordController.text.trim();

      var body = {
        'email': loginEmail,
        'password': loginPassword,
      };
      print(body);

      try {

        final response = await apiService.post('login', body);

        if (response['success'] == true) {
          var userData = response['data']['user'];
          var token = response['data']['token'];

          // Save the token
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);

          var role = userData['role'];

          if (role == "seller") {
            Get.to(() => SellerDashboard(), arguments: userData);
          } else if (role == "buyer") {
            Get.to(() => BuyerHome(), arguments: userData);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Undefined Role!'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                margin: const EdgeInsets.only(bottom: 12, right: 20, left: 20),
              ),
            );

          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: ${response['message'] ?? "Registration failed!"}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              margin: const EdgeInsets.only(bottom: 12, right: 20, left: 20),
            ),
          );

        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            margin: const EdgeInsets.only(bottom: 12, right: 20, left: 20),
          ),
        );

      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: offWhite,
        title: const Text(
          "SignIn",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: lime300,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: offWhite,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: SingleChildScrollView(
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: loginEmailController,
                        // style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          fillColor: offWhite,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          labelText: 'Email',
                        ),
                        validator: (value) {
                          if (value!.isEmpty || !value.contains('@')) {
                            return "Please enter a valid Email address";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: loginPasswordController,
                        obscureText: true,
                        // style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          fillColor: offWhite,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),

                          labelText: 'Password',
                        ),

                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter a password";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30.0),
                    ],
                  ),
                ),
                RoundButton(
                  title: "Sign in",
                  onTap: _login,
                ),
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(onTap: (){
                      Get.to(() =>  BuyerHome());
                    },child: const Text("Don't have an account? ")),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => const SignUp());
                      },
                      child: Card(
                        color: lime300,
                        child: const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            "Create Account",
                            style: TextStyle(
                              color: offWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
