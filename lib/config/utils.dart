import 'package:fitness_management_app/config/constants.dart';

String getImageUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http')) {
    // Old record with hardcoded IP — extract path and rebase to current server
    return '${Env.baseUrl}${Uri.parse(path).path}';
  }
  // New record with relative path
  return '${Env.baseUrl}$path';
}