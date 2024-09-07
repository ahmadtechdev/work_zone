import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:work_zone/widgets/colors.dart';

class Starter extends StatefulWidget {
  const Starter({super.key});

  @override
  State<Starter> createState() => _StarterState();
}

class _StarterState extends State<Starter> {
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xFFEEEEEE),
        title: SvgPicture.asset(
          'lib/assets/img/logo/logo-light.svg',
          height: MediaQuery.sizeOf(context).height / 7,
          width: MediaQuery.sizeOf(context).width / 4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        toolbarHeight: MediaQuery.of(context).size.height / 3,
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Join as a Client or Freelancer",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildCustomRadioTile(
              'I\'m a client',
              'Looking for help with a ...',
              'client',
              Icons.person,
            ),
            SizedBox(height: 10),
            _buildCustomRadioTile(
              'I\'m a freelancer',
              'Looking for my favorite ...',
              'freelancer',
              Icons.work,
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity, // <-- match_parent

              child: ElevatedButton(
                onPressed: () {

                },
                child: const Text('Create Account'),
                style: ElevatedButton.styleFrom(
                    foregroundColor: white,
                    backgroundColor: primary),
              ),
            ),
            SizedBox(height: 20),
            const Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("Already have an account? "),
                Text(
                  "Log In",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: primary
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomRadioTile(
      String title, String subtitle, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RadioListTile<String>(
        title: Row(
          children: [
            Icon(icon, color: _selectedOption == value ? primary : dark100),
            SizedBox(width: 10),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        subtitle: Text(subtitle),
        value: value,
        groupValue: _selectedOption,
        onChanged: (String? newValue) {
          setState(() {
            _selectedOption = newValue;
          });
        },
        activeColor: Colors.green,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }
}
