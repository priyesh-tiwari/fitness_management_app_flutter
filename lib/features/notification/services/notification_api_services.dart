// lib/services/notification_api_service.dart

import 'dart:convert';
import 'package:fitness_management_app/config/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationApiService {
  static const String baseUrl = Env.baseUrl;

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Save FCM token
  Future<bool> saveFCMToken(String fcmToken) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/notifications/fcm-token'),
        headers: headers,
        body: json.encode({'fcmToken': fcmToken}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error saving FCM token: $e');
      return false;
    }
  }

  // Update reminder settings
  Future<bool> updateReminderSettings({
    bool? enabled,
    bool? endOfDayReminder,
    String? time,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = <String, dynamic>{};
      if (enabled != null) body['enabled'] = enabled;
      if (endOfDayReminder != null) body['endOfDayReminder'] = endOfDayReminder;
      if (time != null) body['time'] = time;

      final response = await http.put(
        Uri.parse('$baseUrl/api/notifications/settings'),
        headers: headers,
        body: json.encode(body),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating reminder settings: $e');
      return false;
    }
  }

  // Get reminder settings
  Future<Map<String, dynamic>?> getReminderSettings() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications/settings'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
      return null;
    } catch (e) {
      print('Error getting reminder settings: $e');
      return null;
    }
  }

  // Get notifications
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications'),
        headers: headers,
      );
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      }
      return [];
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  // Mark single notification as read
  Future<bool> markAsRead(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/api/notifications/$id/read'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/api/notifications/read-all'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking all as read: $e');
      return false;
    }
  }

  // Delete single notification
  Future<bool> deleteNotification(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/notifications/$id'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  // Clear all notifications
  Future<bool> clearAll() async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/notifications/clear-all'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error clearing notifications: $e');
      return false;
    }
  }
}