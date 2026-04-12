import 'package:fitness_management_app/config/constants.dart';
import 'package:fitness_management_app/features/attendance/services/attendance_service.dart';
import 'package:fitness_management_app/features/attendance/screens/subscription_weekly_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WeeklyAttendancePreview extends StatefulWidget {
  const WeeklyAttendancePreview({super.key});

  @override
  State<WeeklyAttendancePreview> createState() => _WeeklyAttendancePreviewState();
}

class _WeeklyAttendancePreviewState extends State<WeeklyAttendancePreview> {
  final AttendanceService _attendanceService = AttendanceService();
  bool _isLoading = true;
  Map<String, dynamic>? _subscriptionData;
  List<bool> _weekAttendance = List.filled(7, false);
  int _attendanceCount = 0;
  int _streak = 0;
  List<String> _scheduledDays = [];

  @override
  void initState() {
    super.initState();
    _loadFirstSubscriptionAttendance();
  }

  Future<void> _loadFirstSubscriptionAttendance() async {
    setState(() => _isLoading = true);
    try {
      final result = await _attendanceService.getMyAttendance();
      if (result['success'] == true && result['data'] != null) {
        final subscriptions = result['data'] as List;
        if (subscriptions.isNotEmpty) {
          final subscriptionId = subscriptions[0]['_id'];
          final weeklyResult = await _attendanceService.getSubscriptionWeekly(subscriptionId);
          if (weeklyResult['success'] == true && weeklyResult['data'] != null) {
            _processWeeklyData(weeklyResult['data']);
          }
        }
      }
    } catch (e) {
      print('Error loading attendance: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _processWeeklyData(Map<String, dynamic> data) {
    _subscriptionData = data;
    if (data['schedule'] != null && data['schedule']['days'] != null) {
      _scheduledDays = List<String>.from(data['schedule']['days']);
    }
    final weeklyAttendance = data['weeklyAttendance'] as List? ?? [];
    final now       = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    _weekAttendance = List.filled(7, false);
    for (var att in weeklyAttendance) {
      final attDate  = DateTime.parse(att['date']);
      final daysDiff = attDate.difference(weekStart).inDays;
      if (daysDiff >= 0 && daysDiff < 7) _weekAttendance[daysDiff] = true;
    }
    _attendanceCount = 0;
    for (int i = 0; i < 7; i++) {
      if (_scheduledDays.contains(_getDayName(i)) && _weekAttendance[i]) _attendanceCount++;
    }
    _streak = _calculateStreak();
  }

  String _getDayName(int index) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[index];
  }

  int _calculateStreak() {
    int streak = 0;
    final now = DateTime.now();
    for (int i = now.weekday - 1; i >= 0; i--) {
      if (_scheduledDays.contains(_getDayName(i))) {
        if (_weekAttendance[i]) streak++;
        else break;
      }
    }
    return streak;
  }

  int _getTotalScheduledDays() {
    int count = 0;
    for (int i = 0; i < 7; i++) {
      if (_scheduledDays.contains(_getDayName(i))) count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final outerDecoration = BoxDecoration(
      gradient: LinearGradient(
        colors: [AppTheme.primary.withOpacity(0.5), AppTheme.primary.withOpacity(0.0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(17.r),
      boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2))],
    );

    final innerDecoration = BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(16.r),
    );

    if (_isLoading) {
      return Container(
        decoration: outerDecoration,
        padding: EdgeInsets.all(1.2.w),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: innerDecoration,
          child: Center(
            child: SizedBox(
              width: 28.w,
              height: 28.w,
              child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2.5.w),
            ),
          ),
        ),
      );
    }

    if (_subscriptionData == null) {
      return Container(
        decoration: outerDecoration,
        padding: EdgeInsets.all(1.2.w),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: innerDecoration,
          child: Center(
            child: Text('No active subscriptions', style: TextStyle(color: AppTheme.textMuted, fontSize: 14.sp)),
          ),
        ),
      );
    }

    final totalScheduledDays = _getTotalScheduledDays();
    final programName        = _subscriptionData!['programName'] ?? 'Program';

    return Container(
      decoration: outerDecoration,
      padding: EdgeInsets.all(1.2.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: innerDecoration,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header ───────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(7.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primary.withOpacity(0.15), AppTheme.primary.withOpacity(0.03)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.calendar_today_rounded, color: const Color.fromARGB(255, 119, 140, 116), size: 16.w),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This Week',
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                      ),
                      Text(
                        programName,
                        style: TextStyle(fontSize: 11.sp, color: const Color.fromARGB(255, 119, 140, 116)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionWeeklyListScreen())),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'View All',
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),
          Container(height: 1, color: AppTheme.primary.withOpacity(0.08)),
          SizedBox(height: 14.h),

          // ── Weekday dots ──────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) => _buildWeekdayDot(['M','T','W','T','F','S','S'][i], i)),
          ),

          SizedBox(height: 16.h),
          Container(height: 1, color: AppTheme.primary.withOpacity(0.08)),
          SizedBox(height: 14.h),

          // ── Stats row ─────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat(
                label: 'Attended',
                value: '$_attendanceCount/$totalScheduledDays',
                icon: Icons.check_circle_outline_rounded,
                color: AppTheme.primary,
              ),
              Container(width: 1, height: 36.h, color: AppTheme.primary.withOpacity(0.1)),
              _buildMiniStat(
                label: 'Streak',
                value: '$_streak days',
                icon: Icons.local_fire_department_rounded,
                color: AppTheme.primary,
              ),
              Container(width: 1, height: 36.h, color: AppTheme.primary.withOpacity(0.1)),
              _buildMiniStat(
                label: 'Total',
                value: '${_subscriptionData!['totalAttendance'] ?? 0}',
                icon: Icons.timeline_rounded,
                color: AppTheme.primary,
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildWeekdayDot(String label, int index) {
    final dayName     = _getDayName(index);
    final isScheduled = _scheduledDays.contains(dayName);
    final isAttended  = _weekAttendance[index];

    final now       = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final dayDate   = weekStart.add(Duration(days: index));
    final isPast    = dayDate.isBefore(now) || dayDate.day == now.day;

    // ── No class / holiday ────────────────────────────────────
    if (!isScheduled) {
      return Column(
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.07),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.withOpacity(0.25), width: 1.5),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.close_rounded, color: Colors.grey.shade400, size: 16.w),
          ),
        ],
      );
    }

    // ── Present ───────────────────────────────────────────────
    if (isAttended) {
      return Column(
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: const Color(0xFF2D6A4F),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1B4332), width: 1.5),
              boxShadow: [
                BoxShadow(color: const Color(0xFF2D6A4F).withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2)),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.sp),
            ),
          ),
        ],
      );
    }

    // ── Absent (scheduled but missed, past day) ───────────────
    if (isPast) {
      return Column(
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFEF9A9A), width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(color: const Color(0xFFC62828), fontWeight: FontWeight.w700, fontSize: 12.sp),
            ),
          ),
        ],
      );
    }

    // ── Future scheduled day ──────────────────────────────────
    return Column(
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.border, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w700, fontSize: 12.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(7.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.15), color.withOpacity(0.03)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: color, size: 16.w),
        ),
        SizedBox(height: 6.h),
        Text(value, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        SizedBox(height: 2.h),
        Text(label, style: TextStyle(fontSize: 10.sp, color: AppTheme.textMuted)),
      ],
    );
  }
}