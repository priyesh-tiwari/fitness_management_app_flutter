import 'dart:convert';
import 'package:fitness_management_app/config/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InsightsService {
  static const String baseUrl = Env.apiUrl;

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Generate AI-powered insights (on-demand)
  Future<Map<String, dynamic>> generateInsights() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/insights/generate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'No data available for insights'
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to generate insights. Please try again.'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}'
      };
    }
  }
}