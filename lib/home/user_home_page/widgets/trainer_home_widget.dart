import 'package:fitness_management_app/config/constants.dart';
import 'package:fitness_management_app/features/attendance/screens/qr_scanner_screen.dart';
import 'package:fitness_management_app/features/auth/providers/auth_provider.dart';
import 'package:fitness_management_app/features/programs/screens/create_program_screen.dart';
import 'package:fitness_management_app/features/subscriptions/screens/admin_subscribers_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminSection extends ConsumerWidget {
  const AdminSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider).user?.role;
    if (role != 'trainer') return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 10.w) / 2;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_rounded, color: Colors.white, size: 16.w),
                  SizedBox(width: 4.w),
                  Text(
                    'Trainer',
                    style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // ── Scan QR full width ──────────────────────────────
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QRScannerScreen())),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primary.withOpacity(0.5), AppTheme.primary.withOpacity(0.0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(17.r),
                  boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                padding: EdgeInsets.all(1.2.w),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(9.w),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(Icons.qr_code_scanner_rounded, color: AppTheme.primary, size: 20.w),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scan QR Code',
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Mark member attendance instantly',
                              style: TextStyle(fontSize: 11.sp, color: AppTheme.textMuted),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.textMuted, size: 13.w),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 10.h),

            // ── Two cards ───────────────────────────────────────
            Row(
              children: [
                _buildSquareCard(
                  context,
                  width: cardWidth,
                  icon: Icons.add_circle_outline_rounded,
                  title: 'Add Program',
                  subtitle: 'Create new',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateProgramScreen())),
                ),
                SizedBox(width: 10.w),
                _buildSquareCard(
                  context,
                  width: cardWidth,
                  icon: Icons.people_outline_rounded,
                  title: 'Subscribers',
                  subtitle: 'View all',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSubscribersScreen())),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSquareCard(BuildContext context, {
    required double width,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: width * 0.5,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary.withOpacity(0.5), AppTheme.primary.withOpacity(0.0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(17.r),
            boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          padding: EdgeInsets.all(1.2.w),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(7.w),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, color: AppTheme.primary, size: 18.w),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 10.sp, color: AppTheme.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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