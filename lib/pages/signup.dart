import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:work_zone/widgets/colors.dart';
import 'package:work_zone/widgets/snackbar.dart';

import '../service/api_service.dart';
import '../widgets/button.dart';
import 'signin.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final ApiService apiService = ApiService();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final countryController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();
  bool _isLoading = false;
  String _selectedType = "buyer";
  final _formKey = GlobalKey<FormState>();

  Map<String, List<String>> countryCityMap = {
    'United States': ['New York', 'Los Angeles', 'Chicago'],
    'Canada': ['Toronto', 'Vancouver', 'Montreal'],
    'India': ['Delhi', 'Mumbai', 'Bangalore'],
    'Pakistan': ['Karachi', 'Lahore', 'Islamabad', 'Faisalabad', 'Rawalpindi'],
  };

  List<String> cities = [];

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    countryController.dispose();
    cityController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Set this to true
      appBar: _buildAppBar(),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(color: offWhite),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: SingleChildScrollView( // Keep this for scrolling
            child: Column(
              children: [
                _buildLogo(context),
                Form(
                  key: _formKey,
                  child: _buildFormFields(),
                ),
                const SizedBox(height: 30.0),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RoundButton(title: "Create Account", onTap: _register),
                const SizedBox(height: 20.0),
                _buildLoginPrompt(),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      backgroundColor: offWhite,
      title: const Text(
        "SignUp",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      foregroundColor: primary,
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 200.0,
      width: 250,
      child: SvgPicture.asset(
        'lib/assets/img/logo/logo-light.svg',
        height: MediaQuery.sizeOf(context).height / 9,
      ),
    );
  }

  Column _buildFormFields() {
    return Column(
      children: [
        _buildTextFormField(firstNameController, "First Name", "Please enter First Name", 3),
        const SizedBox(height: 10.0),
        _buildTextFormField(lastNameController, "Last Name", "Please enter Last Name", 3),
        const SizedBox(height: 10.0),
        _buildPhoneField(),
        const SizedBox(height: 10.0),
        _buildTextFormField(emailController, "Email", "Please enter a valid Email address", 0, isEmail: true),
        const SizedBox(height: 10.0),
        _buildAccountTypeDropdown(),
        const SizedBox(height: 10.0),
        _buildCountryPicker(),
        const SizedBox(height: 10.0),
        if (cities.isNotEmpty) _buildCityDropdown(),
        const SizedBox(height: 10.0),
        _buildTextFormField(addressController, "Address", "Please enter address", 3),
        const SizedBox(height: 10.0),
        _buildTextFormField(passwordController, "Password", "Please enter a password", 0, isPassword: true),
      ],
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: phoneController,
      decoration: _buildInputDecoration("Phone"),
      validator: (value) {
        String pattern = r'^[0-9]{11}$';
        RegExp regExp = RegExp(pattern);
        if (value!.length != 11) {
          return 'Enter a valid 11-digit mobile number';
        } else if (!regExp.hasMatch(value)) {
          return 'Please enter a valid mobile number';
        }
        return null;
      },
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      fillColor: Colors.white,
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
      labelText: label,
    );
  }

  Widget _buildTextFormField(
      TextEditingController controller,
      String label,
      String errorMessage,
      int minLength, {
        bool isEmail = false,
        bool isPassword = false,
      }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: _buildInputDecoration(label),
      validator: (value) {
        if (value!.isEmpty) {
          return errorMessage;
        } else if (minLength > 0 && value.length < minLength) {
          return '$label must be more than $minLength characters';
        } else if (isEmail && !value.contains('@')) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildAccountTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      decoration: _buildInputDecoration('Account Type'),
      items: const [
        DropdownMenuItem(value: "buyer", child: Text("Buyer")),
        DropdownMenuItem(value: "seller", child: Text("Seller")),
      ],
      onChanged: (String? newValue) {
        setState(() {
          _selectedType = newValue!;
        });
      },
    );
  }

  Widget _buildCountryPicker() {
    return TextFormField(
      controller: countryController,
      readOnly: true,
      onTap: _showCountryPicker,
      decoration: _buildInputDecoration("Country").copyWith(suffixIcon: const Icon(Icons.arrow_drop_down)),
      validator: (value) {
        if (value!.isEmpty) return "Please select a country";
        return null;
      },
    );
  }

  Widget _buildCityDropdown() {
    return DropdownButtonFormField<String>(
      value: cityController.text.isNotEmpty ? cityController.text : null,
      items: cities.map((String city) {
        return DropdownMenuItem<String>(
          value: city,
          child: Text(city),
        );
      }).toList(),
      decoration: _buildInputDecoration("City"),
      onChanged: (value) {
        setState(() {
          cityController.text = value!;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please select a city';
        return null;
      },
    );
  }

  Row _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account? "),
        GestureDetector(
          onTap: () => Get.to(() => const SignInScreen()),
          child: const Card(
            color: primary,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                "Login",
                style: TextStyle(color: offWhite, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      countryListTheme: _buildCountryListTheme(),
      onSelect: (Country country) {
        setState(() {
          // countryController.text = '${country.name} (${country.countryCode}) [${country.phoneCode}]';
          countryController.text = country.name;
          cities = countryCityMap[countryController.text] ?? [];
          cityController.clear();
        });
      },
    );
  }

  CountryListThemeData _buildCountryListTheme() {
    return const CountryListThemeData(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(40.0), topRight: Radius.circular(40.0)),
      textStyle: TextStyle(fontSize: 16, color: Colors.blueGrey),
      inputDecoration: InputDecoration(
        labelText: 'Search',
        hintText: 'Start typing to search',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Set loading to true when request starts
      });
      try {
        Map<String, String> body = {
          'fname': firstNameController.text,
          'lname': lastNameController.text,
          'phone': phoneController.text,
          'email': emailController.text,
          'country': countryController.text,
          'city': cityController.text,
          'role': _selectedType,
          'address': addressController.text,
          'password': passwordController.text,
        };
        // Call the signupUser method in ApiService
        final response = await apiService.post("register",body);

        if (response['success'] == true) {
          // Show success message
          _showSnackBar("Registration successful!", Colors.green);
          Get.off(() => const SignInScreen());
        } else {
          // Extract error messages and show them in the snackbar
          String errorMessage = response['message'] ?? "Registration failed!";

          if (response['errors'] != null) {
            errorMessage = response['errors']
                .values
                .map((errors) => errors.join("\n"))
                .join("\n");
          }
          _showSnackBar(errorMessage, Colors.red);
        }

        print(response);
      } catch (e) {
        // Handle error
        _showSnackBar('An unexpected error occurred.', Colors.red);
        print(e);
      }finally {
        setState(() {
          _isLoading = false; // Reset loading to false after request completes
        });
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    final snackBar = CustomSnackBar(message: message, backgroundColor: color);
    snackBar.show(context);
  }
}
