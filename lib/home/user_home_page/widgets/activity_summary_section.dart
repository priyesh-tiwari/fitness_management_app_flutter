import 'package:fitness_management_app/config/constants.dart';
import 'package:fitness_management_app/features/activity/provider/activity_provider.dart';
import 'package:fitness_management_app/features/activity/screens/activity_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QuickStatsSection extends ConsumerWidget {
  const QuickStatsSection({super.key});

  int _calculateGoalProgress(activityState) {
    final activity = activityState.todayActivity;
    if (activity == null) return 0;
    int completed = 0;
    if (activity.waterIntake >= activity.goals.waterIntake) completed++;
    if (activity.totalExerciseDuration >= activity.goals.exerciseDuration) completed++;
    if (activity.meditation >= activity.goals.meditation) completed++;
    if (activity.sleepTime >= activity.goals.sleepTime) completed++;
    return ((completed / 4) * 100).round();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityState = ref.watch(activityProvider);

    if (activityState.isLoading && activityState.todayActivity == null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Center(child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2.5.w)),
      );
    }

    final activity     = activityState.todayActivity;
    final calories     = activity?.caloriesBurned ?? 0;
    final activeTime   = activity?.totalExerciseDuration ?? 0;
    final workouts     = activity?.exercises.length ?? 0;
    final goalProgress = _calculateGoalProgress(activityState);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Progress",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.5),
        ),
        SizedBox(height: 12.h),

        Row(
          children: [
            Expanded(child: _buildStatCard(icon: Icons.local_fire_department_rounded, value: '$calories',      label: 'Calories')),
            SizedBox(width: 10.w),
            Expanded(child: _buildStatCard(icon: Icons.timer_rounded,                 value: '$activeTime',    label: 'Minutes')),
            SizedBox(width: 10.w),
            Expanded(child: _buildStatCard(icon: Icons.fitness_center_rounded,        value: '$workouts',      label: 'Workouts')),
            SizedBox(width: 10.w),
            Expanded(child: _buildStatCard(icon: Icons.trending_up_rounded,           value: '$goalProgress%', label: 'Goal')),
          ],
        ),

        SizedBox(height: 12.h),

        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DailyActivityScreen()),
                );
                // No need to manually reload — provider already has updated state
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppTheme.primary),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline_rounded, color: AppTheme.primary, size: 17.w),
                    SizedBox(width: 7.w),
                    Text(
                      'Log Activity',
                      style: TextStyle(fontSize: 15.sp, color: AppTheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({required IconData icon, required String value, required String label}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary.withOpacity(0.12), AppTheme.primary.withOpacity(0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color.fromARGB(255, 119, 140, 116), size: 18.w),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -0.5),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 1.h),
          Text(label, style: TextStyle(fontSize: 10.sp, color: const Color.fromARGB(255, 119, 140, 116), fontWeight: FontWeight.w500)),
          SizedBox(height: 6.h),
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
    );
  }
}