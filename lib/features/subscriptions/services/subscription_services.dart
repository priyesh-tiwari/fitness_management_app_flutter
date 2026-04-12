import 'dart:convert';
import 'package:fitness_management_app/config/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionService {
  static const String baseUrl = Env.apiUrl;

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, dynamic>> initiateSubscription(String programId) async {
    try {
      print('started');
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'no authentication token'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/bookings/initiate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'programId': programId}),
      );
      print(response.body);

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getMySubscriptions({
    int page = 1,
    int limit = 10,
    String? status,
    String? paymentStatus,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token'};
      }

      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (status != null) queryParams['status'] = status;
      if (paymentStatus != null) queryParams['paymentStatus'] = paymentStatus;

      final uri = Uri.parse(
        '$baseUrl/bookings/my-subscriptions',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(response.body);

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getSubscriptionQR(String subscriptionId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/bookings/$subscriptionId/qr'),
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

  Future<Map<String, dynamic>> cancelSubscription(
    String subscriptionId,
    String? reason,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token'};
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/bookings/$subscriptionId/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'cancellationReason': reason}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> renewSubscription(String subscriptionId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/bookings/renew'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'subscriptionId': subscriptionId}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyPayment(String sessionId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/payments/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'sessionId': sessionId}),
      );

      print('Verify payment response: ${response.body}');
      return jsonDecode(response.body);
    } catch (e) {
      print('Verify payment error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
