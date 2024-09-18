// api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

class ApiService {
  final String baseUrl = "http://10.10.0.100:500/api/";
  final String baseUrlImg = "http://10.10.0.100:500/";
  // final String baseUrl = "https://miftag.com/api/";
  // final String baseUrlImg = "https://miftag.com/public/";


  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse(baseUrl + endpoint);
    print(url);
    print(body);

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    print(response);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {

      // Extract error message from response body if possible
      String errorMessage = 'Failed to load data';
      try {
        final errorResponse = jsonDecode(response.body);
        errorMessage = errorResponse['message'] ?? errorMessage;
        print(errorMessage);
      } catch (e) {
        // Handle JSON parsing error
        print(e);
      }
      throw Exception(errorMessage);
    }


  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse(baseUrl + endpoint);
    print(url);

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      print(response);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Extract error message from response body if possible
        String errorMessage = 'Failed to load data';
        try {
          final errorResponse = jsonDecode(response.body);
          errorMessage = errorResponse['message'] ?? errorMessage;
        } catch (e) {
          // Handle JSON parsing error
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Handle network errors or other unexpected issues
      throw Exception('Network error or unexpected issue: $e');
    }
  }
  Future<List<Map<String, dynamic>>> getBuyerOrders() async {
    try {
      final response = await get('buyer-orders');
      if (response['success'] == true && response['orders'] is List) {
        return List<Map<String, dynamic>>.from(response['orders']);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('Error fetching buyer orders: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse(baseUrl + 'user-delete-account');
    final response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete account');
    }
  }



  Future<Map<String, dynamic>> getJob(int jobId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${baseUrl}get-job/$jobId');
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load job');
    }
  }

  Future<Map<String, dynamic>> editJob(int jobId, Map<String, dynamic> jobData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var uri = Uri.parse('${baseUrl}edit-job/$jobId');
    var request = http.MultipartRequest('POST', uri);

    // Add text fields
    jobData.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Add image file if present
    if (jobData['gig_img'] != null && jobData['gig_img'] is File) {
      var file = await http.MultipartFile.fromPath(
          'gig_img',
          jobData['gig_img'].path,
          filename: path.basename(jobData['gig_img'].path)
      );
      request.files.add(file);
    }

    // Add authorization header
    request.headers['Authorization'] = 'Bearer $token';

    // Send the request
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update job: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> deleteJob(int jobId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${baseUrl}delete-job/$jobId');
    final response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete job: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse(baseUrl + 'user-profile');
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load transaction details');
    }
  }

  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> profileData, File? profilePicture) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var uri = Uri.parse(baseUrl + 'update-user-profile');
    var request = http.MultipartRequest('POST', uri);

    // Add text fields
    profileData.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Add profile picture if present
    if (profilePicture != null) {
      var file = await http.MultipartFile.fromPath(
          'profile_picture',
          profilePicture.path,
          filename: path.basename(profilePicture.path)
      );
      request.files.add(file);
    }

    // Add authorization header
    request.headers['Authorization'] = 'Bearer $token';

    // Send the request
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getGigsForUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${baseUrl}all-gigs-foruser');
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('gigs') && data['gigs'] is List) {
          return List<Map<String, dynamic>>.from(data['gigs']);
        } else {
          throw Exception('Invalid data format: gigs not found or not a list');
        }
      } catch (e) {
        print('Error parsing JSON: $e');
        throw Exception('Failed to parse gigs data');
      }
    } else {
      throw Exception('Failed to load gigs');
    }
  }

  Future<Map<String, dynamic>> deleteGig(int gigId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${baseUrl}delete-gig/$gigId');
    print(url);
    final response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete job: ${response.body}');
    }
  }
  Future<Map<String, dynamic>> getGig(int gigId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${baseUrl}get-gig/$gigId');
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load job');
    }
  }

  Future<Map<String, dynamic>> gigUpdate(int gigId, Map<String, dynamic> gigData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var uri = Uri.parse('${baseUrl}update-gig/$gigId');
    var request = http.MultipartRequest('POST', uri);
    print(request);

    // Add text fields
    gigData.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Add image file if present
    if (gigData['gig_img'] != null && gigData['gig_img'] is File) {
      var file = await http.MultipartFile.fromPath(
        'gig_img',
        gigData['gig_img'].path,
        filename: path.basename(gigData['gig_img'].path),
      );
      request.files.add(file);
    }

    // Add authorization header
    request.headers['Authorization'] = 'Bearer $token';

    // Send the request
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update gig: ${response.body}');
    }
  }


  Future<Map<String, dynamic>> storeWithdraw(
      String bankName,
      String accountName,
      String accountNumber,
      double amount,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${baseUrl}store-withdraw');
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        'bank_name': bankName,
        'account_name': accountName,
        'account_no': accountNumber,
        'amount': amount.toInt(),
      }),
    );

    print(response);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to process withdrawal');
    }
  }

  Future<List<Map<String, dynamic>>> getSellerOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${baseUrl}seller-orders');
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData.containsKey('orders') && responseData['orders'] is List) {
        return List<Map<String, dynamic>>.from(responseData['orders']);
      } else {
        throw Exception('Invalid data format: orders not found or not a list');
      }
    } else {
      throw Exception('Failed to load seller orders');
    }
  }

  Future<void> acceptOrder(String orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse(baseUrl + 'accept-order/$orderId');
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      print('Order accepted successfully');
    } else {
      throw Exception('Failed to accept order');
    }
  }

  Future<void> declineOrder(String orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse(baseUrl + 'decline-order/$orderId');
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      print('Order declined successfully');
    } else {
      throw Exception('Failed to decline order');
    }
  }



}