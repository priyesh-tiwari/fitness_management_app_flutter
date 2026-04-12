import 'dart:convert';
import 'package:fitness_management_app/config/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceService {
  static const String baseUrl = Env.apiUrl;

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Mark attendance by scanning QR code
  Future<Map<String, dynamic>> markAttendance(String qrCode) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token'};
      }

      print('📤 Marking attendance with QR: $qrCode');

      final response = await http.post(
        Uri.parse('$baseUrl/attendance/mark'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'qrCode': qrCode}),
      );

      print('📊 Mark Attendance Status: ${response.statusCode}');
      print('📄 Response: ${response.body}');

      return jsonDecode(response.body);
    } catch (e) {
      print('🔴 Mark attendance error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Get my attendance (for students)
  Future<Map<String, dynamic>> getMyAttendance({String? subscriptionId}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token'};
      }

      final queryParams = <String, String>{};
      if (subscriptionId != null) {
        queryParams['subscriptionId'] = subscriptionId;
      }

      final uri = Uri.parse('$baseUrl/attendance/my-attendance')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Keep existing getWeeklyAttendance()

// ADD THIS:
Future<Map<String, dynamic>> getSubscriptionWeekly(String subscriptionId) async {
  try {
    final token = await _getToken();
    if (token == null) {
      return {'success': false, 'message': 'No auth token'};
    }

    final response = await http.get(
      Uri.parse('$baseUrl/attendance/weekly/$subscriptionId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body);
  } catch (e) {
    return {'success': false, 'message': 'Network error: $e'};
  }
}

  // Get program attendance report (for trainers)
  Future<Map<String, dynamic>> getProgramAttendanceReport(String programId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/attendance/program/$programId/report'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}