// [imports remain unchanged]
import 'package:fitness_management_app/config/constants.dart';
import 'package:fitness_management_app/config/utils.dart';
import 'package:fitness_management_app/features/activity/provider/activity_provider.dart';
import 'package:fitness_management_app/features/auth/providers/auth_provider.dart';
import 'package:fitness_management_app/features/notification/providers/notification_provider.dart';
import 'package:fitness_management_app/features/notification/screens/notification_screen.dart';
import 'package:fitness_management_app/features/subscriptions/provider/subscription_provider.dart';
import 'package:fitness_management_app/home/user_home_page/widgets/activity_summary_section.dart';
import 'package:fitness_management_app/home/user_home_page/widgets/explore_program_widget.dart';
import 'package:fitness_management_app/home/user_home_page/widgets/app_drawer.dart';
import 'package:fitness_management_app/home/user_home_page/widgets/greeting_card.dart';
import 'package:fitness_management_app/home/user_home_page/widgets/navigation_section.dart';
import 'package:fitness_management_app/home/user_home_page/widgets/trainer_home_widget.dart';
import 'package:fitness_management_app/home/user_home_page/widgets/weekly_attendance_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserHomeScreen extends ConsumerStatefulWidget {
  const UserHomeScreen({super.key});

  @override
  ConsumerState<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends ConsumerState<UserHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(authProvider.notifier).refreshUser();
      ref.read(subscriptionProvider.notifier).getMySubscriptions(status: 'active');
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState         = ref.watch(authProvider);
    final notificationState = ref.watch(notificationProvider);
    final subscriptionState = ref.watch(subscriptionProvider);
    final user              = authState.user;
    final hasActiveSubscription = subscriptionState.subscriptions.isNotEmpty;
    final isTrainer = user?.role == 'trainer';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(user?.name, user?.profileImage),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () async {
          await ref.read(activityProvider.notifier).loadTodayActivity();
          await ref.read(authProvider.notifier).refreshUser();
          await ref.read(notificationProvider.notifier).refresh();
          await ref.read(subscriptionProvider.notifier).getMySubscriptions(status: 'active');
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                const GreetingCard(),
                SizedBox(height: 16.h),
                const QuickStatsSection(),
                SizedBox(height: 16.h),
                const NavigationSection(),
                SizedBox(height: 16.h),

                if (hasActiveSubscription) ...[
                  Text(
                    'Attendance',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.5),
                  ),
                  SizedBox(height: 12.h),
                  const WeeklyAttendancePreview(),
                ],
                SizedBox(height: 16.h),
                Text(
                  'Explore Programs',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.5),
                ),
                SizedBox(height: 16.h),
                const ExploreProgramsWidget(),

                SizedBox(height: 16.h),

                // Poster for non-trainers
                if (!isTrainer) ...[
                  Text(
                    'Are You a Certified Trainer?',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Unlock exclusive trainer features. Contact the admin or email:',
                    style: TextStyle(fontSize: 14.sp, color: AppTheme.textMuted),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.email_outlined, size: 16.w, color: AppTheme.primary),
                      SizedBox(width: 6.w),
                      Text(
                        'priyesh.ranka@gmail.com',
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: SizedBox(
                      width: double.infinity,
                      height: 260.h, // bigger height
                      child: FittedBox(
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/trainer_access_03.png',
                        ),
                      ),
                    ),
                  ),
                ],

                if (isTrainer) const AdminSection(),

                SizedBox(height: 50.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String? userName, String? profileImage) {
    final unreadCount = ref.watch(notificationProvider).unreadCount;
    final firstLetter = userName?.isNotEmpty == true ? userName![0].toUpperCase() : 'U';
    final hasImage    = profileImage != null && profileImage.isNotEmpty;

    return AppBar(
      backgroundColor: AppTheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: CircleAvatar(
                backgroundColor: AppTheme.accentLight,
                radius: 18.w,
                backgroundImage: hasImage
                    ? NetworkImage(getImageUrl(profileImage))
                    : null,
                child: !hasImage
                    ? Text(
                        firstLetter,
                        style: TextStyle(color: AppTheme.primary, fontSize: 16.sp, fontWeight: FontWeight.w700),
                      )
                    : null,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            'FitTrack',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.5),
          ),
        ],
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(right: 4.w),
              decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(10.r)),
              child: IconButton(
                icon: Icon(
                  unreadCount > 0 ? Icons.notifications_rounded : Icons.notifications_outlined,
                  size: 22.w,
                  color: AppTheme.textPrimary,
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                },
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 6.w,
                top: 8.h,
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: const BoxDecoration(color: AppTheme.danger, shape: BoxShape.circle),
                  constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.w),
                  child: Center(
                    child: Text(
                      unreadCount > 9 ? '9+' : unreadCount.toString(),
                      style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.w700, height: 1),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(width: 8.w),
      ],
    );
  }
}
