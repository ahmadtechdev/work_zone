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
  final EmailController = TextEditingController();
  final PasswordController = TextEditingController();
  final countryController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();
  String _selectedType = "buyer";
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    EmailController.dispose();
    PasswordController.dispose();
    countryController.dispose();
    cityController.dispose();
    addressController.dispose();
  }

  Map<String, List<String>> countryCityMap = {
    'United States (US) [+1]': ['New York', 'Los Angeles', 'Chicago'],
    'Canada (CA) [+1]': ['Toronto', 'Vancouver', 'Montreal'],
    ' India (IN) [+91]': ['Delhi', 'Mumbai', 'Bangalore'],
    'Pakistan (PK) [+92]': [
      'Karachi',
      'Lahore',
      'Islamabad',
      'Faisalabad',
      'Rawalpindi',
      'Multan',
      'Peshawar',
      'Quetta',
      'Sialkot',
      'Bahawalpur',
      'Sargodha',
      'Mardan',
      'Gujranwala',
      'Sheikhupura',
      'Jhelum',
      'Dera Ghazi Khan',
      'Khairpur',
      'Swat',
      'Mirpur',
      'Chiniot',
      'Larkana',
      'Kasur',
      'Okara',
      'Rajanpur'
    ],
  };

  List<String> cities = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: offWhite,
        title: const Text(
          "SignUp",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: lime300,
        // actions: [Icon(Icons.more_vert)],
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
                  height: 200.0,
                  width: 250,
                  child: SvgPicture.asset(
                    'lib/assets/img/logo/logo-light.svg',
                    height: MediaQuery.sizeOf(context).height / 9,
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: firstNameController,
                        // style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          labelText: 'First Name',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter First Name";
                          } else if (value.length < 3) {
                            return 'Name must be more than 2 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: lastNameController,
                        // style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          labelText: 'Last Name',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter Last Name";
                          } else if (value.length < 3) {
                            return 'Name must be more than 2 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: phoneController,
                        // style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          labelText: 'Phone',
                        ),
                        validator: (value) {
                          String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
                          RegExp regExp = RegExp(pattern);
                          if (value!.length == 10) {
                            return 'Enter minimum 10 digit mobile number';
                          } else if (!regExp.hasMatch(value)) {
                            return 'Please enter a valid mobile number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: EmailController,
                        // style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          fillColor: Colors.white,
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
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        // Set the initial value
                        style: const TextStyle(
                          fontSize: 17.0,
                          color: Colors.black, // Ensure the text color is black
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          labelText: 'Account Type',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "buyer",
                            child: Text(
                              "Buyer",
                            ),
                          ),
                          DropdownMenuItem(
                            value: "seller",
                            child: Text("Seller"),
                          ),
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedType =
                                newValue!; // Update the selected value
                          });
                        },
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: countryController,
                        readOnly: true,
                        onTap: _showCountryPicker,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          labelText: 'Country',
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please select a country";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10.0),
                      if (cities.isNotEmpty)
                        DropdownButtonFormField<String>(
                          value: cityController.text.isNotEmpty
                              ? cityController.text
                              : null,
                          items: cities.map((String city) {
                            return DropdownMenuItem<String>(
                              value: city,
                              child: Text(city),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            labelText: 'City',
                          ),
                          onChanged: (value) {
                            setState(() {
                              cityController.text = value!;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a city';
                            }
                            return null;
                          },
                        ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: addressController,
                        // style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          labelText: 'Address',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter address";
                          } else if (value.length < 3) {
                            return 'Name must be more than 2 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: PasswordController,
                        // style: const TextStyle(color: Colors.white),
                        obscureText: true,

                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
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
                  title: "Create Account",
                  onTap: _register,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account ",
                      style: TextStyle(),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => const SignInScreen());
                      },
                      child: const Card(
                          color: lime300,
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Expanded(
                              child: Text("Login",
                                  style: TextStyle(
                                      color: offWhite,
                                      fontWeight: FontWeight.bold)),
                            ),
                          )),
                    ),
                  ],
                ),
                SizedBox(
                  height: 25,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        flagSize: 25,
        backgroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, color: Colors.blueGrey),
        bottomSheetHeight: 500,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        inputDecoration: InputDecoration(
          labelText: 'Search',
          hintText: 'Start typing to search',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xFF8C98A8).withOpacity(0.2),
            ),
          ),
        ),
      ),
      onSelect: (Country country) {
        setState(() {
          String countryName = country.displayName.split('(')[0].trim();
          print(countryName);
          countryController.text = countryName;
          cities = countryCityMap[country.displayName] ?? [];
          cityController.clear(); // Clear the city if country changes
        });
      },
    );
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      Map<String, String> body = {
        'fname': firstNameController.text,
        'lname': lastNameController.text,
        'phone': phoneController.text,
        'email': EmailController.text,
        'country': countryController.text,
        'city': cityController.text,
        'role': _selectedType,
        'address': addressController.text,
        'password': PasswordController.text,
      };

      try {
        final response = await apiService.post("register", body);

        if (response['success'] == true) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Registration successful!"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              margin: const EdgeInsets.only(bottom: 12, right: 20, left: 20),
            ),
          );
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              margin: const EdgeInsets.only(bottom: 12, right: 20, left: 20),
            ),
          );

        }

        print(response);
      } catch (e) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            margin: const EdgeInsets.only(bottom: 12, right: 20, left: 20),
          ),
        );


        print(e);
      }
    }
  }
}
