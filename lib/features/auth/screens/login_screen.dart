import 'package:fitness_management_app/features/auth/screens/email_signup_screen.dart';
import 'package:fitness_management_app/features/auth/providers/auth_provider.dart';
import 'package:fitness_management_app/config/constants.dart';
import 'package:fitness_management_app/features/auth/screens/forgot_password_screen.dart';
import 'package:fitness_management_app/features/auth/screens/name_screen.dart';
import 'package:fitness_management_app/home/user_home_page/user_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> _login() async {
    final email = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).login(email, password);

    if (success && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const UserHomeScreen()),
        (route) => false,
      );
    } else if (mounted) {
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Login failed')),
      );
    }
  }


  Future<void> _googleSignIn() async {
    final result = await ref.read(authProvider.notifier).signInWithGoogle();

    if (!mounted) return;

    if (result['cancelled'] == true) return; // user dismissed — do nothing

    if (result['success'] == true) {
      if (result['isNewUser'] == true) {
        // New Google user — needs username/name
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const NameScreen()),
          (route) => false,
        );
      } else {
        // Existing user — go home
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const UserHomeScreen()),
          (route) => false,
        );
      }
    } else {
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Google sign-in failed')),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth > constraints.maxHeight;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: isLandscape ? 20.h : 60.h),
                    Text(
                      'Log in',
                      style: TextStyle(
                        fontSize: isLandscape ? 24.sp : 32.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: isLandscape ? 16.h : 24.h),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'Phone number, email or username',
                        hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 14.sp),
                        filled: true,
                        fillColor: AppTheme.surface,
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
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: isLandscape ? 12.h : 16.h,
                        ),
                      ),
                    ),
                    SizedBox(height: isLandscape ? 12.h : 16.h),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 14.sp),
                        filled: true,
                        fillColor: AppTheme.surface,
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
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: isLandscape ? 12.h : 16.h,
                        ),
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
                    SizedBox(height: isLandscape ? 16.h : 20.h),
                    SizedBox(
                      width: double.infinity,
                      height: isLandscape ? 48.h : 54.h,
                      child: ElevatedButton(
                        onPressed: authState.isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27.r)),
                          elevation: 0,
                        ),
                        child: authState.isLoading
                            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Get Started', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                                  SizedBox(width: 8.w),
                                  Icon(Icons.arrow_forward, size: 18.sp),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(height: isLandscape ? 8.h : 12.h),
                    // ✅ Forgot password now navigates correctly
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Forgot your login details?  ',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: isLandscape ? 11.sp : 13.sp),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                          ),
                          child: Text(
                            'Get help logging in',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: isLandscape ? 11.sp : 13.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isLandscape ? 16.h : 50.h),
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppTheme.border, thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text('OR', style: TextStyle(color: AppTheme.textMuted, fontSize: isLandscape ? 11.sp : 13.sp, fontWeight: FontWeight.w500)),
                        ),
                        Expanded(child: Divider(color: AppTheme.border, thickness: 1)),
                      ],
                    ),
                    SizedBox(height: isLandscape ? 16.h : 50.h),
                    SizedBox(
                      width: double.infinity,
                      height: isLandscape ? 48.h : 54.h,
                      child: OutlinedButton(
                        onPressed: authState.isLoading ? null : _googleSignIn,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppTheme.surface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27.r)),
                          side: BorderSide(color: AppTheme.border, width: 1.w),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network('https://www.google.com/favicon.ico', height: 20.sp, width: 20.sp),
                            SizedBox(width: 12.w),
                            Text('Log in with Google', style: TextStyle(color: AppTheme.textPrimary, fontSize: 15.sp, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: isLandscape ? 16.h : 50.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?  ", style: TextStyle(color: AppTheme.textMuted, fontSize: isLandscape ? 11.sp : 13.sp)),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const EmailSignupScreen()),
                          ),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: isLandscape ? 11.sp : 13.sp),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isLandscape ? 16.h : 24.h),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}