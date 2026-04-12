import 'package:fitness_management_app/features/auth/providers/auth_provider.dart';
import 'package:fitness_management_app/config/constants.dart';
import 'package:fitness_management_app/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:fitness_management_app/features/auth/screens/set_password_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OTPScreen extends ConsumerStatefulWidget {
  final String email;
  const OTPScreen({super.key, required this.email});

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  final _otpController = TextEditingController();

  Future<void> _verifyOTP() async {
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter 6-digit code')),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).verifyOTP(widget.email, otp);

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SetPasswordScreen(email: widget.email)),
      );
    } else {
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 240.h),

                Text(
                  'Enter OTP',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),

                Text(
                  'To confirm your account, enter the 6 digit code sent to\n${widget.email}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.5,
                    color: AppTheme.textMuted,
                  ),
                ),
                SizedBox(height: 32.h),

                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    hintText: 'Enter 6-digit code',
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
                  ),
                ),
                SizedBox(height: 20.h),

                SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27.r)),
                    ),
                    child: authState.isLoading
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : Text(
                            'Next',
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                  ),
                ),
                SizedBox(height: 16.h),

                Center(
                  child: Text(
                    "Didn't get the code?",
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13.sp),
                  ),
                ),

                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 24.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(fontSize: 13.sp, color: AppTheme.textMuted),
                          ),
                          GestureDetector(
                            onTap: () => {Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => LoginScreen()),
  (route) => false,
)},
                            child: Text(
                              'Log in',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}