import 'package:fitness_management_app/config/constants.dart';
import 'package:fitness_management_app/features/attendance/services/attendance_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';

// Semantic attendance colours — intentional, stay local


class MonthlyAttendanceCalendarScreen extends StatefulWidget {
  final String subscriptionId;
  final String programName;

  const MonthlyAttendanceCalendarScreen({
    super.key,
    required this.subscriptionId,
    required this.programName,
  });

  @override
  State<MonthlyAttendanceCalendarScreen> createState() => _MonthlyAttendanceCalendarScreenState();
}

class _MonthlyAttendanceCalendarScreenState extends State<MonthlyAttendanceCalendarScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  bool _isLoading = true;
  List<String> _scheduledDays = [];
  Set<DateTime> _attendedDates = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int _totalAttendance = 0;

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    setState(() => _isLoading = true);
    try {
      final result = await _attendanceService.getMyAttendance(subscriptionId: widget.subscriptionId);
      if (result['success'] == true && result['data'] != null) {
        final subscriptions = result['data'] as List;
        if (subscriptions.isNotEmpty) {
          final subscription = subscriptions[0];
          if (subscription['program']?['schedule']?['days'] != null) {
            _scheduledDays = List<String>.from(subscription['program']['schedule']['days']);
          }
          final attendanceHistory = subscription['attendanceHistory'] as List? ?? [];
          _attendedDates = attendanceHistory.map((att) {
            final date = DateTime.parse(att['date']);
            return DateTime(date.year, date.month, date.day);
          }).toSet();
          _totalAttendance = subscription['attendanceCount'] ?? 0;
        }
      }
    } catch (e) {
      print('Error loading attendance: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getDayName(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }

  bool _isScheduledDay(DateTime date) => _scheduledDays.contains(_getDayName(date));

  bool _isAttended(DateTime date) => _attendedDates.contains(DateTime(date.year, date.month, date.day));

  Color _getDayColor(DateTime date) {
    final today           = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedDate  = DateTime(date.year, date.month, date.day);

    if (!_isScheduledDay(date))                          return AppTheme.border;
    if (_isAttended(date))                               return AppTheme.kAttended;
    if (normalizedDate.isBefore(normalizedToday))        return AppTheme.kMissed;
    return AppTheme.kUpcoming;
  }

  int _getMonthAttendanceCount() => _attendedDates.where((d) => d.year == _focusedDay.year && d.month == _focusedDay.month).length;

  int _getMonthScheduledDaysCount() {
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDay  = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    int count = 0;
    for (var d = firstDay; !d.isAfter(lastDay); d = d.add(const Duration(days: 1))) {
      if (_isScheduledDay(d) && !d.isAfter(DateTime.now())) count++;
    }
    return count;
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
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20.w),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Attendance Calendar', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
            Text(widget.programName, style: TextStyle(fontSize: 13.sp, color: AppTheme.textMuted, fontWeight: FontWeight.w400)),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2.5.w))
          : Column(
              children: [
                // Stats card
                Container(
                  margin: EdgeInsets.all(16.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AppTheme.border),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('This Month', '${_getMonthAttendanceCount()}/${_getMonthScheduledDaysCount()}', Icons.calendar_today_rounded, AppTheme.kUpcoming),
                      Container(width: 1, height: 40.h, color: AppTheme.border),
                      _buildStatItem('Total', '$_totalAttendance', Icons.check_circle_outline_rounded, AppTheme.kAttended),
                      Container(width: 1, height: 40.h, color: AppTheme.border),
                      _buildStatItem('Days/Week', '${_scheduledDays.length}', Icons.event_repeat_rounded, AppTheme.primary),
                    ],
                  ),
                ),

                // Calendar
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: AppTheme.border),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
                    ),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      calendarFormat: CalendarFormat.month,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() { _selectedDay = selectedDay; _focusedDay = focusedDay; });
                      },
                      onPageChanged: (focusedDay) => setState(() => _focusedDay = focusedDay),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(color: AppTheme.accentLight, shape: BoxShape.circle),
                        selectedDecoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                        outsideDaysVisible: false,
                      ),
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder:  (context, day, _) => _buildCalendarDay(day),
                        todayBuilder:    (context, day, _) => _buildCalendarDay(day, isToday: true),
                        selectedBuilder: (context, day, _) => _buildCalendarDay(day, isSelected: true),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                      ),
                    ),
                  ),
                ),

                // Legend
                Container(
                  margin: EdgeInsets.all(16.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AppTheme.border),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Legend', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 16.w,
                        runSpacing: 8.h,
                        children: [
                          _buildLegendItem(AppTheme.kAttended,    'Attended'),
                          _buildLegendItem(AppTheme.kMissed,      'Missed'),
                          _buildLegendItem(AppTheme.kUpcoming,    'Upcoming'),
                          _buildLegendItem(AppTheme.border, 'Non-class day'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCalendarDay(DateTime day, {bool isToday = false, bool isSelected = false}) {
    final color      = _getDayColor(day);
    final isAttended = _isAttended(day);

    return Container(
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primary : (isAttended ? color : Colors.transparent),
        shape: BoxShape.circle,
        border: isToday ? Border.all(color: AppTheme.primary, width: 2) : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                color: isSelected || isAttended ? Colors.white : color,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13.sp,
              ),
            ),
            if (isAttended)
              Icon(Icons.check_rounded, size: 10.w, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22.w),
        SizedBox(height: 6.h),
        Text(value, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        Text(label, style: TextStyle(fontSize: 11.sp, color: AppTheme.textMuted)),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16.w, height: 16.w, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 6.w),
        Text(label, style: TextStyle(fontSize: 13.sp, color: AppTheme.textPrimary)),
      ],
    );
  }
}