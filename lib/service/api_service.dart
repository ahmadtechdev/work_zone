// api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

class ApiService {
  final String baseUrl = "http://10.10.0.151:500/api/";
  final String baseUrlImg = "http://10.10.0.151:500/";

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse(baseUrl + endpoint);
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
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

  Future<Map<String, dynamic>> logoutAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse(baseUrl + 'logout');
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to logout account');
    }
  }

  Future<Map<String, dynamic>> updatePassword(String currentPassword, String newPassword, String newPasswordConfirmation) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse(baseUrl + 'user-update-password');
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update password');
    }
  }

  Future<Map<String, dynamic>> storeJob(Map<String, dynamic> jobData) async {
    return await post('store-job', jobData);
  }

  Future<List<dynamic>> getJobs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse(baseUrl + 'get-jobs');
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        return responseData['jobs'];
      } else {
        throw Exception('Error fetching jobs: ${responseData['message']}');
      }
    } else {
      throw Exception('Failed to load jobs');
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

  Future<Map<String, dynamic>> getBuyerAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${baseUrl}buyer-account');
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

  Future<Map<String, dynamic>> getTransactionDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse(baseUrl + 'transaction-details');
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

  Future<Map<String, dynamic>> storeBalance(String senderName, String tid, double amount) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse(baseUrl + 'store-balance');
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        'sender_name': senderName,
        'tid': tid,
        'amount': amount,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to store balance');
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

  Future<Map<String, dynamic>> getSellerAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('${baseUrl}my-account');
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



}