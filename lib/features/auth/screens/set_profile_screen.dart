import 'dart:io';
import 'package:fitness_management_app/features/auth/providers/auth_provider.dart';
import 'package:fitness_management_app/config/constants.dart';
import 'package:fitness_management_app/features/auth/screens/login_screen.dart';
import 'package:fitness_management_app/features/auth/screens/terms_condition_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePictureScreen extends ConsumerStatefulWidget {
  const ProfilePictureScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfilePictureScreen> createState() => _ProfilePictureScreenState();
}

class _ProfilePictureScreenState extends ConsumerState<ProfilePictureScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isPickingImage = false;

  Future<void> _pickImage() async {
    if (_isPickingImage) return;
    _isPickingImage = true;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() => _selectedImage = File(image.path));
      }
    } catch (e) {
      debugPrint("Image picker error: $e");
    } finally {
      _isPickingImage = false;
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a profile picture')),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).uploadProfileImage(_selectedImage!);

    if (success) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsScreen()));
    } else {
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Failed')),
      );
    }
  }

  Future<void> _skipProfilePicture() async {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsScreen()));
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
                  'Add a profile picture',
                  style: TextStyle(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 5.h),

                Text(
                  'You can always change it later',
                  style: TextStyle(fontSize: 13.sp, color: AppTheme.textMuted),
                ),
                SizedBox(height: 40.h),

                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 140.w,
                      height: 140.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.border, width: 2.w),
                        color: AppTheme.surface,
                        image: _selectedImage != null
                            ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: _selectedImage == null
                          ? Center(child: Icon(Icons.person, size: 100.sp, color: AppTheme.textMuted))
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 32.h),

                SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _uploadProfilePicture,
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

                SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: OutlinedButton(
                    onPressed: authState.isLoading ? null : _skipProfilePicture,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppTheme.surface,
                      side: BorderSide(color: AppTheme.border, width: 1.w),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27.r)),
                    ),
                    child: Text(
                      'Skip',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    ),
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
                            onTap: () {Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => LoginScreen()),
  (route) => false,
);},
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
}