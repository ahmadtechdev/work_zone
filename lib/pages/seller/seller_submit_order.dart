import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:work_zone/widgets/colors.dart';
import 'package:work_zone/service/api_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class SellerSubmitOrder extends StatefulWidget {
  const SellerSubmitOrder({Key? key}) : super(key: key);

  @override
  _SellerSubmitOrderState createState() => _SellerSubmitOrderState();
}

class _SellerSubmitOrderState extends State<SellerSubmitOrder> {
  final ApiService _apiService = ApiService();
  final TextEditingController _commentsController = TextEditingController();

  String? _fileName;
  String? _filePath;
  String orderId = Get.arguments['order_id'].toString();
  Map<String, dynamic> orderData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrderData();
  }

  Future<void> _fetchOrderData() async {
    try {
      final data = await _apiService.get('seller-order-info/$orderId');
      setState(() {
        orderData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  Future<bool> _requestStoragePermission() async {
    final permissionStatus = await Permission.storage.status;
    if (permissionStatus.isDenied) {
      // Request permission
      final result = await Permission.storage.request();
      if (result.isDenied) {
        // If still denied after request, open app settings
        await openAppSettings();
        return false;
      }
      return result.isGranted;
    } else if (permissionStatus.isPermanentlyDenied) {
      // If permanently denied, open app settings
      await openAppSettings();
      return false;
    }
    return permissionStatus.isGranted;
  }

  Future<void> _pickFile() async {
    bool hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission is required to pick a file')),
      );
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        setState(() {
          _fileName = result.files.single.name;
          _filePath = result.files.single.path;
        });
      }
    } catch (e) {
      print('Error picking file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
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
      body: isLoading
          ? _buildSkeletonLoader()
          : SingleChildScrollView(
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
          ].animate().fade(duration: 500.ms, delay: 100.ms).scale(begin: const Offset(0.8, 0.8)),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(3, (index) =>
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget content}) {
    return Container(
      width: double.infinity,
      child: Card(

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
      ),
    );
  }

  Widget _buildServicePackageInfo() {
    final gig = orderData['gig'] ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Service: ${gig['title'] ?? 'N/A'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        Text('Details:', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        Html(
          data: gig['description'] ?? 'No details available',
          // style: {
          //   "body": Style(
          //     fontSize: FontSize(14),
          //     margin: EdgeInsets.zero,
          //     padding: EdgeInsets.zero,
          //   ),
          // },
        ),
      ],
    );
  }
  Widget _buildBuyerInfo() {
    final buyer = orderData['buyer'] ?? {};
    return Row(
      children: [
        const CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage('lib/assets/img/others/1.png'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${buyer['fname'] ?? ''} ${buyer['lname'] ?? ''}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${buyer['buyer_city'] ?? ''}, ${buyer['buyer_country'] ?? ''}',
                  style: const TextStyle(fontSize: 14)),
              Text('Member Since: ${_formatDate(buyer['buyer_created_at'])}',
                  style: const TextStyle(fontSize: 14)),
              // Note: Total Jobs is not available in the API response
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildSubmitWorkForm() {
    final order = orderData['order'] ?? {};
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
        Text('Submit Date: ${_formatDate(DateTime.now().toIso8601String())}',
            style: const TextStyle(fontSize: 14)),
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
        Text('Status: ${order['status'] ?? 'N/A'}', style: TextStyle(fontSize: 14)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildActionButton(
              label: 'Close',
              color: Colors.red,
              onPressed: () => Get.back(),
            ),
            const SizedBox(width: 10),
            _buildActionButton(
              label: 'Submit',
              color: primary,
              onPressed: _submitWork,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submitWork() async {
    if (_filePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file to upload')),
      );
      return;
    }

    bool hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission is required to upload the file')),
      );
      return;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${_apiService.baseUrl}submit-order/$orderId'),
      );

      // Add file
      var file = await http.MultipartFile.fromPath(
        'work_file',
        _filePath!,
        filename: path.basename(_filePath!),
      );
      request.files.add(file);

      // Add comment
      request.fields['quick_response'] = _commentsController.text;

      // Add authorization header
      var prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('token') ?? '';
      request.headers['Authorization'] = 'Bearer $token';

      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Work submitted successfully')),
          );
          Get.back();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit work: ${result['message']}')),
          );
        }
      } else {
        throw Exception('Failed to submit work: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
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

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    final date = DateTime.parse(dateString);
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[month - 1];
  }


}