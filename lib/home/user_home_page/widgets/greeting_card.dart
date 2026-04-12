import 'dart:math';
import 'package:fitness_management_app/config/constants.dart';
import 'package:fitness_management_app/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GreetingCard extends ConsumerStatefulWidget {
  const GreetingCard({super.key});

  @override
  ConsumerState<GreetingCard> createState() => _GreetingCardState();
}

class _GreetingCardState extends ConsumerState<GreetingCard> {
  final List<String> _quotes = [
    'The only bad workout is the one that didn\'t happen.',
    'Your body can stand almost anything. It\'s your mind you have to convince.',
    'Success starts with self-discipline.',
    'Push yourself, because no one else is going to do it for you.',
    'The pain you feel today will be the strength you feel tomorrow.',
    'Don\'t limit your challenges. Challenge your limits.',
  ];

  late String _currentQuote;

  @override
  void initState() {
    super.initState();
    _currentQuote = _quotes[Random().nextInt(_quotes.length)];
  }

  void _refreshQuote() {
    setState(() {
      _currentQuote = _quotes[Random().nextInt(_quotes.length)];
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 17) return Icons.wb_sunny_rounded;
    return Icons.nightlight_round;
  }

  String _getFirstName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'User';
    return fullName.split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
    final user      = ref.watch(authProvider).user;
    final firstName = _getFirstName(user?.name);

    // Gradient border wrapper
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.6),
            AppTheme.primary.withOpacity(0.0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(17.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(1.2.w), // border thickness
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // ── Left: greeting + name + quote ────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_getGreetingIcon(), color: const Color.fromARGB(255, 200, 209, 166), size: 14.w),
                      SizedBox(width: 5.w),
                      Text(
                        _getGreeting(),
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    firstName,
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '"$_currentQuote"',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11.sp,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            SizedBox(width: 12.w),

            // ── Right: icon + refresh ─────────────────────────
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_getGreetingIcon(), color: const Color.fromARGB(255, 229, 203, 126), size: 22.w),
                ),
                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: _refreshQuote,
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Icon(Icons.refresh_rounded, color: const Color.fromARGB(255, 18, 25, 18), size: 14.w),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}