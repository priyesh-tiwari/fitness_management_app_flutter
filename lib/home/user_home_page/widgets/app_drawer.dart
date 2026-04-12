import 'dart:io';
import 'package:fitness_management_app/config/constants.dart';
import 'package:fitness_management_app/config/utils.dart';
import 'package:fitness_management_app/features/auth/providers/auth_provider.dart';
import 'package:fitness_management_app/features/auth/screens/login_screen.dart';
import 'package:fitness_management_app/features/profile/profile_screen.dart';
import 'package:fitness_management_app/features/subscriptions/screens/my_subscription_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  Future<void> _changeProfileImage(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Change Profile Photo',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
              SizedBox(height: 16.h),
              ListTile(
                leading: Icon(Icons.camera_alt_outlined, color: AppTheme.primary, size: 22.w),
                title: Text('Take Photo', style: TextStyle(fontSize: 15.sp, color: AppTheme.textPrimary)),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library_outlined, color: AppTheme.primary, size: 22.w),
                title: Text('Choose from Gallery', style: TextStyle(fontSize: 15.sp, color: AppTheme.textPrimary)),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;

    final success = await ref.read(authProvider.notifier).uploadProfileImage(File(picked.path));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Profile photo updated' : 'Failed to update photo')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user        = ref.watch(authProvider).user;
    final firstLetter = user?.name?.isNotEmpty == true ? user!.name![0].toUpperCase() : 'U';
    final hasImage    = user?.profileImage != null && user!.profileImage!.isNotEmpty;

    return Drawer(
      backgroundColor: AppTheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Hero header ───────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 24.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color.fromARGB(255, 61, 98, 82).withOpacity(0.85), const Color.fromARGB(255, 217, 223, 220).withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _changeProfileImage(context, ref),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 32.w,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        backgroundImage: hasImage ? NetworkImage(getImageUrl(user?.profileImage)) : null,
                        child: !hasImage
                            ? Text(
                                firstLetter,
                                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700, color: Colors.white),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.primary, width: 1.5),
                          ),
                          child: Icon(Icons.camera_alt, size: 10.w, color: AppTheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  user?.name ?? 'User',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Text(
                  user?.email ?? 'No email',
                  style: TextStyle(fontSize: 12.sp, color: Colors.white.withOpacity(0.75)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // ── Menu items ────────────────────────────────────
          _item(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          _item(
            icon: Icons.card_membership_outlined,
            label: 'Subscriptions',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MySubscriptionsScreen()));
            },
          ),

          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.fitness_center_rounded, color: AppTheme.primary, size: 18.w),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FitTrack', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      Text('Stay fit, stay healthy', style: TextStyle(fontSize: 11.sp, color: AppTheme.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: GestureDetector(
              onTap: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: AppTheme.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
                    title: Text('Logout',
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    content: Text('Are you sure you want to logout?',
                        style: TextStyle(fontSize: 14.sp, color: AppTheme.textMuted)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Cancel',
                            style: TextStyle(fontSize: 14.sp, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('Logout',
                            style: TextStyle(fontSize: 14.sp, color: AppTheme.danger, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                );
                if (shouldLogout == true) {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                }
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 13.h),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 69, 124, 101).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppTheme.primary),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, size: 18.w, color: AppTheme.primary),
                    SizedBox(width: 8.w),
                    Text('Logout', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color     = isDestructive ? AppTheme.danger : AppTheme.textPrimary;
    final iconColor = isDestructive ? AppTheme.textMuted : AppTheme.textMuted;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: isDestructive ? AppTheme.background : AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, size: 18.w, color: iconColor),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: color),
              ),
            ),
            if (!isDestructive)
              Icon(Icons.chevron_right_rounded, size: 18.w, color: AppTheme.border),
          ],
        ),
      ),
    );
  }
}