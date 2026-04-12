import 'package:fitness_management_app/config/constants.dart';
import 'package:fitness_management_app/features/activity/models/daily_activity_model.dart';
import 'package:fitness_management_app/features/activity/services/activity_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



class ActivityAnalysisScreen extends StatefulWidget {
  const ActivityAnalysisScreen({super.key});

  @override
  State<ActivityAnalysisScreen> createState() => _ActivityAnalysisScreenState();
}

class _ActivityAnalysisScreenState extends State<ActivityAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DailyActivityService _service = DailyActivityService();

  WeeklyAnalysis?  weeklyData;
  MonthlyAnalysis? monthlyData;
  bool isLoadingWeekly  = true;
  bool isLoadingMonthly = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadWeeklyData();
    _loadMonthlyData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWeeklyData() async {
    if (!mounted) return;
    setState(() => isLoadingWeekly = true);
    final res = await _service.getWeeklyAnalysis();
    if (!mounted) return;
    setState(() {
      if (res['success'] == true && res['data'] != null) {
        weeklyData = WeeklyAnalysis.fromJson(res['data']);
      }
      isLoadingWeekly = false;
    });
  }

  Future<void> _loadMonthlyData() async {
    if (!mounted) return;
    setState(() => isLoadingMonthly = true);
    final res = await _service.getMonthlyAnalysis();
    if (!mounted) return;
    setState(() {
      if (res['success'] == true && res['data'] != null) {
        monthlyData = MonthlyAnalysis.fromJson(res['data']);
      }
      isLoadingMonthly = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildWeeklyTab(), _buildMonthlyTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppTheme.surface,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 8.h, 16.w, 0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20.w),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  'Activity Analysis',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 20.sp, fontWeight: FontWeight.w700, letterSpacing: -0.3),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textMuted,
            indicatorColor: AppTheme.primary,
            indicatorWeight: 2.5,
            labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            tabs: [
              Tab(icon: Icon(Icons.calendar_view_week_rounded, size: 20.w), text: 'Weekly'),
              Tab(icon: Icon(Icons.calendar_month_rounded, size: 20.w), text: 'Monthly'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTab() {
    if (isLoadingWeekly) return _loader();
    if (weeklyData == null) return _empty();
    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: _loadWeeklyData,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        children: [
          _buildStreakCard(weeklyData!.streak),
          SizedBox(height: 16.h),
          _buildWeeklyStatsCard(),
          SizedBox(height: 16.h),
          _buildAveragesCard('Weekly Averages', weeklyData!.averages.water,
              weeklyData!.averages.exercise, weeklyData!.averages.meditation,
              weeklyData!.averages.sleep, weeklyData!.averages.calories),
          SizedBox(height: 16.h),
          _buildActivitiesList(weeklyData!.activities),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildMonthlyTab() {
    if (isLoadingMonthly) return _loader();
    if (monthlyData == null) return _empty();
    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: _loadMonthlyData,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        children: [
          _buildMonthCard(),
          SizedBox(height: 16.h),
          _buildAveragesCard('Monthly Averages', monthlyData!.averages.water,
              monthlyData!.averages.exercise, monthlyData!.averages.meditation,
              monthlyData!.averages.sleep, monthlyData!.averages.calories),
          SizedBox(height: 16.h),
          _buildGoalAchievementCard(),
          SizedBox(height: 16.h),
          _buildActivitiesList(monthlyData!.activities),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  // Streak card — green gradient, no orange
  Widget _buildStreakCard(int streak) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.kSuccessGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
            child: Icon(Icons.local_fire_department_rounded, color: AppTheme.primary, size: 36.w),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Streak', style: TextStyle(color: Colors.white70, fontSize: 13.sp, fontWeight: FontWeight.w500)),
                SizedBox(height: 4.h),
                Text(
                  '$streak ${streak == 1 ? 'Day' : 'Days'}',
                  style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.w700, letterSpacing: -0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyStatsCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('Week Overview'),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem('Active Days',    '${weeklyData!.totalDays}',       Icons.calendar_today_rounded,        AppTheme.primary),
              _statItem('Total Calories', '${weeklyData!.totals.calories}', Icons.local_fire_department_rounded, AppTheme.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCard() {
    return _Card(
      child: Column(
        children: [
          Text(monthlyData!.month, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem('Active Days',  '${monthlyData!.totalDays}',       Icons.calendar_today_rounded, AppTheme.primary),
              _statItem('Perfect Days', '${monthlyData!.perfectDays}',     Icons.emoji_events_rounded,   AppTheme.kGold),
              _statItem('Success Rate', '${monthlyData!.completionRate}%', Icons.trending_up_rounded,    AppTheme.kSuccessGreen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12.r)),
          child: Icon(icon, color: color, size: 24.w),
        ),
        SizedBox(height: 8.h),
        Text(value, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.5)),
        SizedBox(height: 2.h),
        Text(label, style: TextStyle(fontSize: 11.sp, color: AppTheme.textMuted)),
      ],
    );
  }

  Widget _buildAveragesCard(String title, int water, int exercise, int meditation, double sleep, int calories) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(title),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(child: _avgItem('💧', '${water}ml',                    'Water')),
              Expanded(child: _avgItem('🏃', '${exercise}min',               'Exercise')),
              Expanded(child: _avgItem('🧘', '${meditation}min',             'Meditation')),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width - 80.w) / 3,
                child: _avgItem('😴', '${sleep.toStringAsFixed(1)}h', 'Sleep'),
              ),
              SizedBox(width: 16.w),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 80.w) / 3,
                child: _avgItem('🔥', '$calories', 'Calories'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avgItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: 28.sp)),
        SizedBox(height: 8.h),
        Text(value, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppTheme.primary)),
        SizedBox(height: 2.h),
        Text(label, style: TextStyle(color: AppTheme.textMuted, fontSize: 12.sp)),
      ],
    );
  }

  Widget _buildGoalAchievementCard() {
    final g = monthlyData!.goalsAchieved;
    final t = monthlyData!.totalDays;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('Goals Achieved This Month'),
          SizedBox(height: 20.h),
          _goalBar('💧 Water',      g.water,      t),
          SizedBox(height: 12.h),
          _goalBar('🏃 Exercise',   g.exercise,   t),
          SizedBox(height: 12.h),
          _goalBar('🧘 Meditation', g.meditation, t),
          SizedBox(height: 12.h),
          _goalBar('😴 Sleep',      g.sleep,      t),
        ],
      ),
    );
  }

  Widget _goalBar(String label, int achieved, int total) {
    final pct = total > 0 ? achieved / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp, color: AppTheme.textPrimary)),
            Text('$achieved / $total days', style: TextStyle(color: AppTheme.textMuted, fontSize: 12.sp)),
          ],
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8.h,
            backgroundColor: AppTheme.accentLight,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildActivitiesList(List<DailyActivity> activities) {
    if (activities.isEmpty) {
      return _Card(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: Center(child: Column(children: [
            Icon(Icons.inbox_outlined, size: 60.w, color: AppTheme.border),
            SizedBox(height: 12.h),
            Text('No activity recorded yet', style: TextStyle(color: AppTheme.textMuted, fontSize: 15.sp)),
          ])),
        ),
      );
    }

    return _Card(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(children: [
              Icon(Icons.history_rounded, color: AppTheme.primary, size: 22.w),
              SizedBox(width: 12.w),
              Text('Daily Records', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.2)),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(color: AppTheme.accentLight, borderRadius: BorderRadius.circular(8.r)),
                child: Text('${activities.length} days', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 11.sp)),
              ),
            ]),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: AppTheme.border),
            itemBuilder: (context, index) {
              final a = activities[activities.length - 1 - index];
              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                leading: CircleAvatar(
                  backgroundColor: a.areAllGoalsMet ? AppTheme.kSuccessGreen.withOpacity(0.1) : AppTheme.background,
                  child: Icon(
                    a.areAllGoalsMet ? Icons.check_rounded : Icons.calendar_today_rounded,
                    color: a.areAllGoalsMet ? AppTheme.kSuccessGreen : AppTheme.textMuted,
                    size: 20.w,
                  ),
                ),
                title: Text(_formatDate(a.date), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp, color: AppTheme.textPrimary)),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(
                    '${a.waterIntake}ml · ${a.totalExerciseDuration}min · ${a.meditation}min · ${a.sleepTime}h',
                    style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted),
                  ),
                ),
                trailing: a.areAllGoalsMet ? Icon(Icons.emoji_events_rounded, color: AppTheme.kGold, size: 22.w) : null,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _loader() => Center(child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2.5.w));
  Widget _empty()  => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.error_outline_rounded, size: 60.w, color: AppTheme.border),
    SizedBox(height: 12.h),
    Text('No data available', style: TextStyle(color: AppTheme.textMuted, fontSize: 16.sp)),
  ]));
  Widget _title(String t) => Text(t, style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.2));

  String _formatDate(DateTime date) {
    const days   = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding});
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }
}