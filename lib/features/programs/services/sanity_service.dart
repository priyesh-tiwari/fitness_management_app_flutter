import 'dart:convert';
import 'package:http/http.dart' as http;

class SanityService {
  static const String _projectId = 'z2u24c4j';
  static const String _dataset = 'production';
  static const String _apiVersion = 'v2024-01-01';

  static String get _baseUrl =>
      'https://$_projectId.api.sanity.io/$_apiVersion/data/query/$_dataset';

  Future<Map<String, dynamic>> _query(String groq) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {'query': groq},
    );

    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'result': []};
    } catch (e) {
      return {'result': []};
    }
  }

  // Fetch all programs with trainer info
  Future<Map<String, dynamic>> getAllPrograms() async {
    const groq = '''
      *[_type == "program"] {
        _id,
        name,
        description,
        programType,
        price,
        duration,
        location,
        difficulty,
        status,
        schedule,
        capacity,
        _createdAt,
        _updatedAt,
        "trainer": trainer-> {
          _id,
          name,
          email,
          "profileImage": profileImage.asset->url
        }
      }
    ''';
    return _query(groq);
  }

  // Fetch single program by ID
  Future<Map<String, dynamic>> getProgramById(String id) async {
    final groq = '''
      *[_type == "program" && _id == "$id"][0] {
        _id,
        name,
        description,
        programType,
        price,
        duration,
        location,
        difficulty,
        status,
        schedule,
        capacity,
        _createdAt,
        _updatedAt,
        "trainer": trainer-> {
          _id,
          name,
          email,
          "profileImage": profileImage.asset->url
        }
      }
    ''';
    return _query(groq);
  }
}