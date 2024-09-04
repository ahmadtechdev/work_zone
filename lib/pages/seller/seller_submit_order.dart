import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:work_zone/widgets/colors.dart';

class SellerSubmitOrder extends StatefulWidget {
  const SellerSubmitOrder({super.key});

  @override
  _SellerSubmitOrderState createState() => _SellerSubmitOrderState();
}

class _SellerSubmitOrderState extends State<SellerSubmitOrder> {
  String? _fileName;
  final TextEditingController _commentsController = TextEditingController();

  Future<void> _pickFile() async {
    try {
      // Request permissions before picking a file
      var status = await Permission.storage.request();
      if (status.isGranted) {
        FilePickerResult? result = await FilePicker.platform.pickFiles();
        if (result != null) {
          setState(() {
            _fileName = result.files.single.name;
          });
        }
      } else {
        // Handle the case where permission is denied
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Work'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: 'Service & Package Information',
              content: _buildServicePackageInfo(),
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              title: 'Buyer Info',
              content: _buildBuyerInfo(),
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              title: 'Submit Work',
              content: _buildSubmitWorkForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget content}) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildServicePackageInfo() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Service: HTML', style: TextStyle(fontSize: 16)),
        SizedBox(height: 5),
        Text('Details:', style: TextStyle(fontSize: 16)),
        Text('✓ This is details', style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildBuyerInfo() {
    return const Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage('lib/assets/img/others/1.png'),
        ),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Moaze', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Faisalabad, Pakistan', style: TextStyle(fontSize: 14)),
            Text('Member Since: 04 Sep 2024', style: TextStyle(fontSize: 14)),
            Text('Total Jobs: 1', style: TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }
  Widget _buildSubmitWorkForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text('Choose File'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _fileName ?? 'No file chosen',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text('Submit Date: 04 Sep 2024, 10:50 AM', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 10),
        TextField(
          controller: _commentsController,
          decoration: const InputDecoration(
            labelText: 'Comments',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 10),
        const Text('Status: Delivered', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildActionButton(
              label: 'Close',
              color: Colors.red,
              onPressed: () {
                // Handle close action
              },
            ),
            const SizedBox(width: 10),
            _buildActionButton(
              label: 'Submit',
              color: lime300,
              onPressed: () {
                // Handle submit action
              },
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: white),
      child: Text(label),
    );
  }
}
