import 'package:fitness_management_app/config/constants.dart';
import 'package:fitness_management_app/features/attendance/screens/monthly_calendar_screen.dart';
import 'package:fitness_management_app/features/attendance/services/attendance_service.dart';
import 'package:fitness_management_app/features/programs/provider/program_provider.dart';
import 'package:fitness_management_app/features/programs/screens/program_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



class SubscriptionWeeklyListScreen extends StatefulWidget {
  const SubscriptionWeeklyListScreen({super.key});

  @override
  State<SubscriptionWeeklyListScreen> createState() =>
      _SubscriptionWeeklyListScreenState();
}

class _SubscriptionWeeklyListScreenState
    extends State<SubscriptionWeeklyListScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _subscriptionsList = [];

  @override
  void initState() {
    super.initState();
    _loadAllSubscriptions();
  }

  Future<void> _loadAllSubscriptions() async {
    setState(() => _isLoading = true);
    try {
      final result = await _attendanceService.getMyAttendance();
      if (result['success'] == true && result['data'] != null) {
        final subscriptions = result['data'] as List;
        final List<Map<String, dynamic>> processedSubs = [];
        for (var sub in subscriptions) {
          final weeklyResult = await _attendanceService.getSubscriptionWeekly(
            sub['_id'],
          );
          if (weeklyResult['success'] == true && weeklyResult['data'] != null) {
            processedSubs.add(weeklyResult['data']);
          }
        }
        setState(() => _subscriptionsList = processedSubs);
      }
    } catch (e) {
      print('Error loading subscriptions: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPrimary,
            size: 20.w,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Weekly Attendance',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
                strokeWidth: 2.5.w,
              ),
            )
          : _subscriptionsList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy_rounded,
                    size: 60.w,
                    color: AppTheme.border,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'No active subscriptions',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: AppTheme.primary,
              onRefresh: _loadAllSubscriptions,
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: _subscriptionsList.length,
                itemBuilder: (context, index) => _SubscriptionWeeklyCard(
                  subscription: _subscriptionsList[index],
                  onMonthlyTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MonthlyAttendanceCalendarScreen(
                        subscriptionId:
                            _subscriptionsList[index]['subscriptionId'],
                        programName:
                            _subscriptionsList[index]['programName'] ??
                            'Program',
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _SubscriptionWeeklyCard extends ConsumerWidget {
  final Map<String, dynamic> subscription;
  final VoidCallback onMonthlyTap;

  const _SubscriptionWeeklyCard({
    required this.subscription,
    required this.onMonthlyTap,
  });

  String _getDayName(int index) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[index];
  }

  List<bool> _getWeekAttendance() {
    final weeklyAttendance = subscription['weeklyAttendance'] as List? ?? [];
    final now = DateTime.now();
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - 1),
    );
    final result = List.filled(7, false);
    for (var att in weeklyAttendance) {
      final parsed = DateTime.parse(att['date']);
      final local = parsed.toLocal();
      final diff = local.difference(weekStart).inDays;
      if (diff >= 0 && diff < 7) result[diff] = true;
    }
    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('subscription keys: ${subscription.keys.toList()}');
print('programId value: ${subscription['programId']}');
    final programName = subscription['programName'] ?? 'Program';
    final programId = subscription['programId']?.toString();
    final scheduledDays = subscription['schedule']?['days'] != null
        ? List<String>.from(subscription['schedule']['days'])
        : <String>[];
    final totalAttendance = subscription['totalAttendance'] ?? 0;
    final weekAttendance = _getWeekAttendance();

    int attendanceCount = 0;
    int totalScheduled = 0;
    for (int i = 0; i < 7; i++) {
      if (scheduledDays.contains(_getDayName(i))) {
        totalScheduled++;
        if (weekAttendance[i]) attendanceCount++;
      }
    }

    final isPerfect = attendanceCount == totalScheduled && totalScheduled > 0;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ Same pattern as ProgramCard — getProgramById then navigate
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: programId != null
                            ? () async {
                                print("Program name tapped : $programId");
                                await ref
                                    .read(programProvider.notifier)
                                    .getProgramById(programId);
                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProgramDetailScreen(
                                        programId: programId,
                                      ),
                                    ),
                                  );
                                }
                              }
                            : null,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                programName,
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w700,
                                  color: programId != null
                                      ? AppTheme.primary
                                      : AppTheme.textPrimary,
                                  decoration: programId != null
                                      ? TextDecoration.underline
                                      : TextDecoration.none,
                                  decorationColor: AppTheme.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (programId != null) ...[
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.open_in_new_rounded,
                                size: 12.w,
                                color: AppTheme.primary,
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Total Attendance: $totalAttendance',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                // ✅ Arrow → monthly screen
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onMonthlyTap,
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 20.w,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // ── Weekday dots ──────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                7,
                (i) => _buildDayDot(
                  ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                  i,
                  weekAttendance,
                  scheduledDays,
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // ── Footer ────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'This Week: $attendanceCount/$totalScheduled',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: isPerfect
                        ? AppTheme.kAttended.withOpacity(0.1)
                        : AppTheme.accentLight,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    isPerfect ? 'Perfect!' : 'In Progress',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: isPerfect ? AppTheme.kAttended : AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayDot(
    String label,
    int index,
    List<bool> weekAttendance,
    List<String> scheduledDays,
  ) {
    final isScheduled = scheduledDays.contains(_getDayName(index));
    final isAttended = weekAttendance[index];
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final dayDate = weekStart.add(Duration(days: index));
    final isPast = dayDate.isBefore(now) || dayDate.day == now.day;

    Color bg;
    Color fg;
    if (!isScheduled) {
      bg = AppTheme.border;
      fg = AppTheme.textMuted;
    } else if (isAttended) {
      bg = AppTheme.kAttended;
      fg = Colors.white;
    } else {
      bg = isPast ? AppTheme.kMissed.withOpacity(0.12) : AppTheme.background;
      fg = isPast ? AppTheme.kMissed : AppTheme.textMuted;
    }

    return Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: 13.sp,
        ),
      ),
    );
  }
}
