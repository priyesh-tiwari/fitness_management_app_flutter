import 'dart:convert';
import 'package:fitness_management_app/config/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProgramService {
  // Use the same base URL as ApiService
  static const String baseUrl = Env.apiUrl;

  // Get token from SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // 1. Get all programs with filters and pagination
  Future<Map<String, dynamic>> getAllPrograms({
    int page = 1,
    int limit = 10,
    String? programType,
    String? difficulty,
    String? trainer,
    int? minPrice,
    int? maxPrice,
    String? search,
    String? sortBy,
    String? order,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (programType != null) queryParams['programType'] = programType;
      if (difficulty != null) queryParams['difficulty'] = difficulty;
      if (trainer != null) queryParams['trainer'] = trainer;
      if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
      if (search != null) queryParams['search'] = search;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (order != null) queryParams['order'] = order;

      final uri = Uri.parse(
        '$baseUrl/sessions',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // 2. Get program by ID
  Future<Map<String, dynamic>> getProgramById(String programId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sessions/$programId'),
        headers: {'Content-Type': 'application/json'},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // 3. Get programs by trainer
  Future<Map<String, dynamic>> getProgramsByTrainer(String trainerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sessions/trainer/$trainerId'),
        headers: {'Content-Type': 'application/json'},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // 4. Create program (Trainer only)
  Future<Map<String, dynamic>> createProgram({
    required String name,
    String? description,
    required String programType,
    required double price,
    List<String>? days,
    String? startTime,
    String? endTime,
    int? maxParticipants,
    String? location,
    String? difficulty,
  }) async {
    print('Create program run succesfully!');
    try {
      final token = await _getToken();

      if (token == null) {
        return {'success': false, 'message': 'No authentication token'};
      }

      final body = <String, dynamic>{
        'name': name,
        'programType': programType,
        'price': price,
      };

      if (description != null) body['description'] = description;
      if (location != null) body['location'] = location;
      if (difficulty != null) body['difficulty'] = difficulty;

      // Add schedule if provided
      if (days != null && startTime != null && endTime != null) {
        body['schedule'] = {
          'days': days,
          'time': {'start': startTime, 'end': endTime},
        };
      }

      // Add capacity if provided
      if (maxParticipants != null) {
        body['capacity'] = {'maxParticipants': maxParticipants};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/sessions/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('STATUS CODE: ${response.statusCode}');
      print('RAW RESPONSE: ${response.body}');

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // 5. Update program
  Future<Map<String, dynamic>> updateProgram(
    String programId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return {'success': false, 'message': 'No authentication token'};
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/sessions/$programId/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updates),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // 6. Delete program
  Future<Map<String, dynamic>> deleteProgram(String programId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return {'success': false, 'message': 'No authentication token'};
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/sessions/$programId/delete'),
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

  // 7. Get program subscribers (Trainer only)
  Future<Map<String, dynamic>> getProgramSubscribers(String programId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return {'success': false, 'message': 'No authentication token'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/sessions/$programId/subscribers'),
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
}
