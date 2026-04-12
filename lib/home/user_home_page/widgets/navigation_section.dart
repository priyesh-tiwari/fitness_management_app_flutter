import 'package:fitness_management_app/config/constants.dart';
import 'package:fitness_management_app/features/insights/screens/insights_screen.dart';
import 'package:fitness_management_app/features/subscriptions/screens/my_subscription_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NavigationSection extends ConsumerWidget {
  const NavigationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.5),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(child: _buildCard(context, icon: Icons.card_membership_outlined, title: 'Subscriptions', subtitle: 'My plans', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MySubscriptionsScreen())))),
            SizedBox(width: 12.w),
            Expanded(child: _buildCard(context, icon: Icons.insights_rounded,         title: 'AI Insights',   subtitle: 'Get tips', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InsightsScreen())))),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(9.w),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, color: const Color.fromARGB(255, 119, 140, 116), size: 20.w),
              ),
              SizedBox(height: 10.h),
              Text(title,    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
              SizedBox(height: 2.h),
              Text(subtitle, style: TextStyle(fontSize: 11.sp, color: const Color.fromARGB(255, 119, 140, 116)),maxLines: 1, overflow:TextOverflow.ellipsis),
              SizedBox(height: 6.h),
              // ── Faded green line ──────────────────────────────
              Container(
                height: 2.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary.withOpacity(0.7),
                      AppTheme.primary.withOpacity(0.0),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}