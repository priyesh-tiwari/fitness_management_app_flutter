import 'package:fitness_management_app/config/constants.dart';
import 'package:fitness_management_app/features/auth/providers/auth_provider.dart';
import 'package:fitness_management_app/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  // Step 1 = enter email, Step 2 = enter OTP, Step 3 = enter new password
  int _step = 1;
  String _email = '';

  final _emailController      = TextEditingController();
  final _otpController        = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm  = true;

  // Step 1: Send OTP
  Future<void> _sendOTP() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showSnack('Please enter a valid email');
      return;
    }
    final res = await ref.read(authProvider.notifier).sendForgotPasswordOTP(email);
    if (res['success'] == true) {
      setState(() {
        _email = email;
        _step  = 2;
      });
    } else {
      _showSnack(res['message'] ?? 'Failed to send OTP');
    }
  }

  // Step 2: Verify OTP
  Future<void> _verifyOTP() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      _showSnack('Please enter the 6-digit OTP');
      return;
    }
    final res = await ref.read(authProvider.notifier).verifyForgotPasswordOTP(_email, otp);
    if (res['success'] == true) {
      setState(() => _step = 3);
    } else {
      _showSnack(res['message'] ?? 'Invalid OTP');
    }
  }

  // Step 3: Reset Password
  Future<void> _resetPassword() async {
    final newPassword     = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.length < 6) {
      _showSnack('Password must be at least 6 characters');
      return;
    }
    if (newPassword != confirmPassword) {
      _showSnack('Passwords do not match');
      return;
    }

    final res = await ref.read(authProvider.notifier).resetPassword(_email, newPassword);
    if (res['success'] == true) {
      _showSnack('Password reset successfully');
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } else {
      _showSnack(res['message'] ?? 'Failed to reset password');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20.w),
            onPressed: () {
              if (_step > 1) {
                setState(() => _step--);
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Text(
                  _step == 1 ? 'Forgot Password' : _step == 2 ? 'Enter OTP' : 'New Password',
                  style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                SizedBox(height: 8.h),
                Text(
                  _step == 1
                      ? 'Enter your registered email to receive an OTP'
                      : _step == 2
                          ? 'We sent a 6-digit OTP to $_email'
                          : 'Enter your new password',
                  style: TextStyle(fontSize: 14.sp, color: AppTheme.textMuted, height: 1.5),
                ),
                SizedBox(height: 32.h),

                // Step 1: Email
                if (_step == 1) ...[
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration('Email'),
                  ),
                  SizedBox(height: 20.h),
                  _primaryButton('Send OTP', isLoading, _sendOTP),
                ],

                // Step 2: OTP
                if (_step == 2) ...[
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: _inputDecoration('6-digit OTP'),
                  ),
                  SizedBox(height: 20.h),
                  _primaryButton('Verify OTP', isLoading, _verifyOTP),
                  SizedBox(height: 16.h),
                  Center(
                    child: GestureDetector(
                      onTap: isLoading ? null : _sendOTP,
                      child: Text(
                        'Resend OTP',
                        style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 14.sp),
                      ),
                    ),
                  ),
                ],

                // Step 3: New Password
                if (_step == 3) ...[
                  TextField(
                    controller: _newPasswordController,
                    obscureText: _obscurePassword,
                    decoration: _inputDecoration('New Password').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppTheme.textMuted,
                          size: 20.sp,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    decoration: _inputDecoration('Confirm Password').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppTheme.textMuted,
                          size: 20.sp,
                        ),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _primaryButton('Reset Password', isLoading, _resetPassword),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 14.sp),
      filled: true,
      fillColor: AppTheme.surface,
      counterText: '',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(27.r),
        borderSide: BorderSide(color: AppTheme.border, width: 1.w),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(27.r),
        borderSide: BorderSide(color: AppTheme.border, width: 1.w),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(27.r),
        borderSide: BorderSide(color: AppTheme.primary, width: 1.w),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
    );
  }

  Widget _primaryButton(String label, bool isLoading, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27.r)),
          elevation: 0,
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            : Text(label, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}