import 'package:fitness_management_app/features/auth/models/user_model.dart';
import 'package:fitness_management_app/features/auth/services/auth_service.dart';
import 'dart:io';

class AuthRepository {
  Future<bool> isLoggedIn() async => await ApiService.isLoggedIn();

  Future<UserModel?> getCurrentUser() async {
    try {
      final res = await ApiService.getCurrentUser();
      if (res['success'] == true && res['user'] != null) {
        return UserModel.fromJson(res['user']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> sendOTP(String email) async {
    final res = await ApiService.sendOTP(email);
    return res['success'] == true;
  }

  Future<bool> verifyOTP(String email, String otp) async {
    final res = await ApiService.verifyOTP(email, otp);
    return res['success'] == true;
  }

  Future<UserModel?> createPassword(String email, String password) async {
    final res = await ApiService.createPassword(email, password);
    if (res['token'] != null && res['user'] != null) {
      return UserModel.fromJson(res['user']);
    }
    return null;
  }

  Future<UserModel?> completeProfile({String? name, String? username}) async {
    final res = await ApiService.completeProfile(name: name, username: username);
    if (res['success'] == true && res['user'] != null) {
      return UserModel.fromJson(res['user']);
    }
    return null;
  }

  Future<UserModel?> uploadProfileImage(File file) async {
    final res = await ApiService.uploadProfileImage(file);
    if (res['success'] == true && res['user'] != null) {
      return UserModel.fromJson(res['user']);
    }
    return null;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await ApiService.login(email, password);
    if (res['token'] != null) {
      if (res['user'] != null) {
        return {'success': true, 'user': UserModel.fromJson(res['user'])};
      }
      final user = await getCurrentUser();
      return {'success': true, 'user': user};
    }
    return {'success': false, 'error': res['error'] ?? 'Invalid email or password'};
  }

  Future<void> logout() async => await ApiService.removeToken();

  // ── Forgot Password ───────────────────────────────────────
  Future<Map<String, dynamic>> sendForgotPasswordOTP(String email) async {
    return await ApiService.sendForgotPasswordOTP(email);
  }

  Future<Map<String, dynamic>> verifyForgotPasswordOTP(String email, String otp) async {
    return await ApiService.verifyForgotPasswordOTP(email, otp);
  }

  Future<Map<String, dynamic>> resetPassword(String email, String newPassword) async {
    return await ApiService.resetPassword(email, newPassword);
  }

  Future<Map<String, dynamic>> googleSignIn(String idToken) async {
    final res = await ApiService.googleSignIn(idToken);
    if (res['success'] == true && res['user'] != null) {
      return {
        'success': true,
        'user': UserModel.fromJson(res['user']),
        'isNewUser': res['isNewUser'] ?? false,
      };
    }
    return {'success': false, 'error': res['message'] ?? 'Google sign-in failed'};
  }
}