import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fitness_management_app/features/auth/repository/auth_repository.dart';
import 'package:fitness_management_app/features/notification/services/notification_api_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_management_app/features/auth/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Single shared GoogleSignIn instance — industry standard
final _googleSignIn = GoogleSignIn(
  serverClientId: '1023538609736-kaakrb6nvjrrnmfaujgja2a6mvmtlcoq.apps.googleusercontent.com',
);

class AuthState {
  final bool isLoading;
  final UserModel? user;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    UserModel? user,
    String? error,
    bool? isAuthenticated,
    bool clearUser = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : (user ?? this.user),
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository = AuthRepository();

  AuthNotifier() : super(AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    final isLoggedIn = await _repository.isLoggedIn();
    if (isLoggedIn) {
      final user = await _repository.getCurrentUser();
      state = state.copyWith(isAuthenticated: true, user: user, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refreshUser() async {
    final user = await _repository.getCurrentUser();
    if (user != null) state = state.copyWith(user: user);
  }

  Future<bool> sendOTP(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    final success = await _repository.sendOTP(email);
    state = state.copyWith(isLoading: false, error: success ? null : 'Failed to send OTP');
    return success;
  }

  Future<bool> verifyOTP(String email, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    final success = await _repository.verifyOTP(email, otp);
    state = state.copyWith(isLoading: false, error: success ? null : 'Invalid OTP');
    return success;
  }

  Future<bool> createPassword(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final user = await _repository.createPassword(email, password);
    if (user != null) {
      state = state.copyWith(isLoading: false, user: user, isAuthenticated: true);
      return true;
    }
    state = state.copyWith(isLoading: false, error: 'Failed to create password');
    return false;
  }

  Future<bool> completeProfile({String? name, String? username}) async {
    state = state.copyWith(isLoading: true, error: null);
    final updatedUser = await _repository.completeProfile(name: name, username: username);
    if (updatedUser != null) {
      state = state.copyWith(isLoading: false, user: updatedUser);
      return true;
    }
    state = state.copyWith(isLoading: false, error: 'Failed to update profile');
    return false;
  }

  Future<bool> uploadProfileImage(File imageFile) async {
    state = state.copyWith(isLoading: true, error: null);
    final updatedUser = await _repository.uploadProfileImage(imageFile);
    if (updatedUser != null) {
      state = state.copyWith(isLoading: false, user: updatedUser);
      return true;
    }
    state = state.copyWith(isLoading: false, error: 'Failed to upload image');
    return false;
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.login(email, password);
    if (result['success'] == true) {
      state = state.copyWith(isLoading: false, user: result['user'], isAuthenticated: true);
      return true;
    }
    state = state.copyWith(isLoading: false, error: result['error'] ?? 'Invalid email or password');
    return false;
  }

  Future<void> logout() async {
    // Sign out from both our backend and Google
    await _repository.logout();
    try {
      await _googleSignIn.signOut();    // clears cached Google session
      await _googleSignIn.disconnect(); // revokes access — shows account picker next time
    } catch (e) {
      // Google sign out failure should not block app logout
      print('Google sign out error: $e');
    }
    state = AuthState(isLoading: false, user: null, error: null, isAuthenticated: false);
  }

  // ── Forgot Password ───────────────────────────────────────
  Future<Map<String, dynamic>> sendForgotPasswordOTP(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    final res = await _repository.sendForgotPasswordOTP(email);
    state = state.copyWith(isLoading: false);
    return res;
  }

  Future<Map<String, dynamic>> verifyForgotPasswordOTP(String email, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    final res = await _repository.verifyForgotPasswordOTP(email, otp);
    state = state.copyWith(isLoading: false);
    return res;
  }

  Future<Map<String, dynamic>> resetPassword(String email, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    final res = await _repository.resetPassword(email, newPassword);
    state = state.copyWith(isLoading: false);
    return res;
  }

  // ── Google Sign-In ────────────────────────────────────────
  Future<Map<String, dynamic>> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Step 1: Always sign out first to force account picker
      await _googleSignIn.signOut();

      // Step 2: Trigger Google sign-in UI — always shows account picker
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled
        state = state.copyWith(isLoading: false);
        return {'success': false, 'cancelled': true};
      }

      // Step 3: Get Google auth credentials
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        state = state.copyWith(isLoading: false, error: 'Google sign-in failed: no ID token');
        return {'success': false, 'error': 'No ID token received'};
      }

      // Step 4: Send ID token to our backend
      final result = await _repository.googleSignIn(idToken);

      if (result['success'] == true) {
        state = state.copyWith(
          isLoading: false,
          user: result['user'],
          isAuthenticated: true,
        );

        // Step 5: Save FCM token now that JWT is saved
        try {
          final fcmToken = await FirebaseMessaging.instance.getToken();
          if (fcmToken != null) {
            await NotificationApiService().saveFCMToken(fcmToken);
          }
        } catch (e) {
          // FCM token save failure should not block sign-in
          print('FCM token save error: $e');
        }

        return {
          'success': true,
          'isNewUser': result['isNewUser'] ?? false,
        };
      }

      state = state.copyWith(isLoading: false, error: result['error']);
      return {'success': false, 'error': result['error']};

    } catch (e) {
      print('GOOGLE SIGN IN ERROR: $e');
      print('GOOGLE SIGN IN ERROR TYPE: ${e.runtimeType}');
      state = state.copyWith(isLoading: false, error: e.toString());
      return {'success': false, 'error': e.toString()};
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});