// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter_html/flutter_html.dart';
// import 'package:flutter_quill/flutter_quill.dart';
// import 'package:get/get.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
// import 'package:work_zone/widgets/colors.dart';
// import 'package:work_zone/service/api_service.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:http/http.dart' as http;
// import 'package:path/path.dart' as path;
//
// class SellerSubmitOrder extends StatefulWidget {
//   const SellerSubmitOrder({Key? key}) : super(key: key);
//
//   @override
//   _SellerSubmitOrderState createState() => _SellerSubmitOrderState();
// }
//
// class _SellerSubmitOrderState extends State<SellerSubmitOrder> {
//   final ApiService _apiService = ApiService();
//   final TextEditingController _commentsController = TextEditingController();
//
//   String? _fileName;
//   String? _filePath;
//   String orderId = Get.arguments['order_id'].toString();
//   Map<String, dynamic> orderData = {};
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchOrderData();
//   }
//
//   Future<void> _fetchOrderData() async {
//     try {
//       final data = await _apiService.get('seller-order-info/$orderId');
//       setState(() {
//         orderData = data;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading data: $e')),
//       );
//     }
//   }
//
//   Future<bool> _requestStoragePermission() async {
//     final permissionStatus = await Permission.storage.status;
//     if (permissionStatus.isDenied) {
//       // Request permission
//       final result = await Permission.storage.request();
//       if (result.isDenied) {
//         // If still denied after request, open app settings
//         await openAppSettings();
//         return false;
//       }
//       return result.isGranted;
//     } else if (permissionStatus.isPermanentlyDenied) {
//       // If permanently denied, open app settings
//       await openAppSettings();
//       return false;
//     }
//     return permissionStatus.isGranted;
//   }
//
//   Future<void> _pickFile() async {
//     bool hasPermission = await _requestStoragePermission();
//     if (!hasPermission) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Storage permission is required to pick a file')),
//       );
//       return;
//     }
//
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles();
//       if (result != null) {
//         setState(() {
//           _fileName = result.files.single.name;
//           _filePath = result.files.single.path;
//         });
//       }
//     } catch (e) {
//       print('Error picking file: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error picking file: $e')),
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     _commentsController.dispose();
//     super.dispose();
//   }
//
//   // ... (rest of the code remains the same)
//
//   Future<void> _submitWork() async {
//     if (_filePath == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a file to upload')),
//       );
//       return;
//     }
//
//     bool hasPermission = await _requestStoragePermission();
//     if (!hasPermission) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Storage permission is required to upload the file')),
//       );
//       return;
//     }
//
//     try {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('${_apiService.baseUrl}submit-order/$orderId'),
//       );
//
//       // Add file
//       var file = await http.MultipartFile.fromPath(
//         'work_file',
//         _filePath!,
//         filename: path.basename(_filePath!),
//       );
//       request.files.add(file);
//
//       // Add comment
//       request.fields['quick_response'] = _commentsController.text;
//
//       // Add authorization header
//       var prefs = await SharedPreferences.getInstance();
//       var token = prefs.getString('token') ?? '';
//       request.headers['Authorization'] = 'Bearer $token';
//
//       // Send the request
//       var streamedResponse = await request.send();
//       var response = await http.Response.fromStream(streamedResponse);
//
//       if (response.statusCode == 200) {
//         var result = jsonDecode(response.body);
//         if (result['status'] == 'success') {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Work submitted successfully')),
//           );
//           Get.back();
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Failed to submit work: ${result['message']}')),
//           );
//         }
//       } else {
//         throw Exception('Failed to submit work: ${response.body}');
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('An error occurred: $e')),
//       );
//     }
//   }
//
// // ... (rest of the code remains the same)
// }