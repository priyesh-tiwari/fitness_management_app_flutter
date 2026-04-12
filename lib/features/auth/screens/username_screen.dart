import 'package:fitness_management_app/features/auth/screens/login_screen.dart';
import 'package:fitness_management_app/features/auth/screens/set_profile_screen.dart';
import 'package:fitness_management_app/features/auth/providers/auth_provider.dart';
import 'package:fitness_management_app/config/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UsernameScreen extends ConsumerStatefulWidget {
  const UsernameScreen({super.key});

  @override
  ConsumerState<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends ConsumerState<UsernameScreen> {
  final _usernameController = TextEditingController();

  String? _validateUsername(String value) {
    if (value.isEmpty) return 'Please enter a username';
    if (value.length < 3) return 'Username must be at least 3 characters';
    if (value.length > 30) return 'Username cannot exceed 30 characters';
    if (!RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9._]{1,28}[a-zA-Z0-9]$').hasMatch(value)) {
      return 'Must start/end with a letter or number. Only letters, numbers, . and _ allowed';
    }
    if (RegExp(r'[._]{2,}').hasMatch(value)) {
      return 'Cannot have consecutive dots or underscores';
    }
    return null;
  }

  Future<void> _saveUsername() async {
    final username = _usernameController.text.trim();

    final validationError = _validateUsername(username);
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).completeProfile(username: username);

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfilePictureScreen()),
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
                  "Create a username",
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),

                Text(
                  "You can always change it later",
                  style: TextStyle(fontSize: 14.sp, color: AppTheme.textMuted, height: 1.5),
                ),
                SizedBox(height: 24.h),

                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: "Username",
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  ),
                ),
                SizedBox(height: 20.h),

                SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _saveUsername,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27.r)),
                      elevation: 0,
                    ),
                    child: authState.isLoading
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : Text("Next", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
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
                            "Already have an account? ",
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 13.sp),
                          ),
                          GestureDetector(
                            onTap: (){Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => LoginScreen()),
  (route) => false,
);},
                            child: Text(
                              "Log in",
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
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
    _usernameController.dispose();
    super.dispose();
  }
}