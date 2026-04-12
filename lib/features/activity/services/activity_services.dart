import 'dart:convert';
import 'package:fitness_management_app/config/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DailyActivityService {
  static const String baseUrl = Env.apiUrl;


  // Internal helpers

  
  static String _withTz(String path) =>
      '$baseUrl$path?tz=${DateTime.now().timeZoneOffset.inMinutes}';

  /// Standard auth + content-type headers.
  static Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  /// Retrieve auth token; returns null if missing.
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Shared guard: returns token or an error map.
  /// Usage:
  ///   final token = await _requireToken();
  ///   if (token == null) return _noTokenError();
  static Future<String?> _requireToken() => _getToken();

  static Map<String, dynamic> _noTokenError() =>
      {'success': false, 'message': 'No authentication token'};

  static Map<String, dynamic> _networkError(Object e) =>
      {'success': false, 'message': 'Network error: $e'};

  // ---------------------------------------------------------------------------
  // Daily snapshot
  // ---------------------------------------------------------------------------

  /// GET /activity/today?tz=<offset>
  /// Returns (or creates) today's activity document with goal progress.
  Future<Map<String, dynamic>> getTodayActivity() async {
    try {
      final token = await _requireToken();
      if (token == null) return _noTokenError();

      final response = await http.get(
        Uri.parse(_withTz('/activity/today')),
        headers: _headers(token),
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return _networkError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Water tracking
  // ---------------------------------------------------------------------------

  /// POST /activity/water?tz=<offset>
  /// [amount] positive to add (ml), negative to subtract.
  Future<Map<String, dynamic>> updateWater(int amount) async {
    try {
      final token = await _requireToken();
      if (token == null) return _noTokenError();

      final response = await http.post(
        Uri.parse(_withTz('/activity/water')),
        headers: _headers(token),
        body: jsonEncode({'amount': amount}),
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return _networkError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Exercise tracking
  // ---------------------------------------------------------------------------

  /// POST /activity/exercise?tz=<offset>
  Future<Map<String, dynamic>> logExercise({
    required String exerciseType,
    required int duration,
    String? customName,
  }) async {
    try {
      final token = await _requireToken();
      if (token == null) return _noTokenError();

      final body = <String, dynamic>{
        'exerciseType': exerciseType,
        'duration': duration,
      };
      if (customName != null && customName.trim().isNotEmpty) {
        body['customName'] = customName.trim();
      }

      final response = await http.post(
        Uri.parse(_withTz('/activity/exercise')),
        headers: _headers(token),
        body: jsonEncode(body),
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return _networkError(e);
    }
  }

  /// DELETE /activity/exercise/:exerciseId?tz=<offset>
  Future<Map<String, dynamic>> deleteExercise(String exerciseId) async {
    try {
      final token = await _requireToken();
      if (token == null) return _noTokenError();

      final response = await http.delete(
        Uri.parse(_withTz('/activity/exercise/$exerciseId')),
        headers: _headers(token),
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return _networkError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Meditation tracking
  // ---------------------------------------------------------------------------

  /// POST /activity/meditation?tz=<offset>
  /// [duration] total minutes for today (sets/overrides, not additive).
  Future<Map<String, dynamic>> setMeditation(int duration) async {
    try {
      final token = await _requireToken();
      if (token == null) return _noTokenError();

      final response = await http.post(
        Uri.parse(_withTz('/activity/meditation')),
        headers: _headers(token),
        body: jsonEncode({'duration': duration}),
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return _networkError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Sleep tracking
  // ---------------------------------------------------------------------------

  /// POST /activity/sleep?tz=<offset>
  /// [hours] total sleep last night in hours (decimals allowed, e.g. 7.5).
  /// Sets/overrides — not additive.
  Future<Map<String, dynamic>> setSleepTime(double hours) async {
    try {
      final token = await _requireToken();
      if (token == null) return _noTokenError();

      final response = await http.post(
        Uri.parse(_withTz('/activity/sleep')),
        headers: _headers(token),
        body: jsonEncode({'hours': hours}),
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return _networkError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Analytics
  // ---------------------------------------------------------------------------

  /// GET /activity/analysis/weekly?tz=<offset>
  /// Returns this ISO week's stats + a streak count that spans beyond 7 days.
  Future<Map<String, dynamic>> getWeeklyAnalysis() async {
    try {
      final token = await _requireToken();
      if (token == null) return _noTokenError();

      final response = await http.get(
        Uri.parse(_withTz('/activity/analysis/weekly')),
        headers: _headers(token),
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return _networkError(e);
    }
  }

  /// GET /activity/analysis/monthly?tz=<offset>
  Future<Map<String, dynamic>> getMonthlyAnalysis() async {
    try {
      final token = await _requireToken();
      if (token == null) return _noTokenError();

      final response = await http.get(
        Uri.parse(_withTz('/activity/analysis/monthly')),
        headers: _headers(token),
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return _networkError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // User settings
  
  Future<Map<String, dynamic>> updateDailyGoals({
    int? waterIntake,
    int? exerciseDuration,
    int? meditation,
    double? sleepTime,   // changed to double — sleep goal can be e.g. 7.5 h
  }) async {
    try {
      final token = await _requireToken();
      if (token == null) return _noTokenError();

      final body = <String, dynamic>{};
      if (waterIntake != null)      body['waterIntake']      = waterIntake;
      if (exerciseDuration != null) body['exerciseDuration'] = exerciseDuration;
      if (meditation != null)       body['meditation']       = meditation;
      if (sleepTime != null)        body['sleepTime']        = sleepTime;

      final response = await http.put(
        Uri.parse(_withTz('/activity/goals')),
        headers: _headers(token),
        body: jsonEncode(body),
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return _networkError(e);
    }
  }

  /// PUT /activity/weight
  /// Weight does not affect date/timezone logic — no tz param needed.
  Future<Map<String, dynamic>> updateWeight(double weight) async {
    try {
      final token = await _requireToken();
      if (token == null) return _noTokenError();

      final response = await http.put(
        Uri.parse('$baseUrl/activity/weight'),
        headers: _headers(token),
        body: jsonEncode({'weight': weight}),
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return _networkError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Notifications
  // NOTE: The backend routes file comment says these two routes were removed
  // from /activity/ and moved to a dedicated notification router.
  // Update the URLs below once you know the exact mounted path of that router.
  // Until then, these are kept as-is to avoid breaking existing callers.
  // ---------------------------------------------------------------------------

  /// Save FCM token for push notifications.
  /// TODO: Update URL to match your notification router mount path.
  Future<Map<String, dynamic>> saveFCMToken(String fcmToken) async {
    try {
      final token = await _requireToken();
      if (token == null) return _noTokenError();

      final response = await http.post(
        Uri.parse('$baseUrl/activity/fcm-token'), // update path when notification router is confirmed
        headers: _headers(token),
        body: jsonEncode({'fcmToken': fcmToken}),
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return _networkError(e);
    }
  }

  /// Update reminder settings.
  /// TODO: Update URL to match your notification router mount path.
  Future<Map<String, dynamic>> updateReminderSettings({
    bool? enabled,
    String? time,
    bool? endOfDayReminder,
  }) async {
    try {
      final token = await _requireToken();
      if (token == null) return _noTokenError();

      final body = <String, dynamic>{};
      if (enabled != null)           body['enabled']           = enabled;
      if (time != null)              body['time']              = time;
      if (endOfDayReminder != null)  body['endOfDayReminder']  = endOfDayReminder;

      final response = await http.put(
        Uri.parse('$baseUrl/activity/reminder'), // update path when notification router is confirmed
        headers: _headers(token),
        body: jsonEncode(body),
      );

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return _networkError(e);
    }
  }
}