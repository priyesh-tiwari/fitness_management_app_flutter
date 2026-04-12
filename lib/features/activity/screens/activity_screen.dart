import 'package:fitness_management_app/config/constants.dart';
import 'package:fitness_management_app/features/activity/models/daily_activity_model.dart';
import 'package:fitness_management_app/features/activity/provider/activity_provider.dart';
import 'package:fitness_management_app/features/activity/screens/activity_analysis_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class DailyActivityScreen extends ConsumerStatefulWidget {
  const DailyActivityScreen({super.key});

  @override
  ConsumerState<DailyActivityScreen> createState() => _DailyActivityScreenState();
}

class _DailyActivityScreenState extends ConsumerState<DailyActivityScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    // Refresh data when screen opens
    Future.microtask(() => ref.read(activityProvider.notifier).loadTodayActivity());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _updateWater(int amount) async {
    final success = await ref.read(activityProvider.notifier).updateWater(amount);
    if (success) {
      final activity = ref.read(activityProvider).todayActivity;
      if (activity != null && activity.isWaterGoalMet) {
        _showGoalSnackbar('Water goal completed! 💧', AppTheme.primary);
      }
    }
  }

  Future<void> _logExercise() async {
    final todayActivity = ref.read(activityProvider).todayActivity;
    if (todayActivity == null) return;

    final types = [
      {'key': 'running',         'name': 'Running',  'icon': Icons.directions_run_rounded},
      {'key': 'walking',         'name': 'Walking',  'icon': Icons.directions_walk_rounded},
      {'key': 'cycling',         'name': 'Cycling',  'icon': Icons.directions_bike_rounded},
      {'key': 'swimming',        'name': 'Swimming', 'icon': Icons.pool_rounded},
      {'key': 'yoga',            'name': 'Yoga',     'icon': Icons.self_improvement_rounded},
      {'key': 'weight_training', 'name': 'Gym',      'icon': Icons.fitness_center_rounded},
      {'key': 'hiit',            'name': 'HIIT',     'icon': Icons.whatshot_rounded},
      {'key': 'dancing',         'name': 'Dancing',  'icon': Icons.music_note_rounded},
    ];

    String selectedType = 'running';
    final durationCtrl  = TextEditingController();
    final nameCtrl      = TextEditingController();

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModal) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24.w, right: 24.w, top: 16.h),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 36.w, height: 4.h,
                    decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2.r)))),
                SizedBox(height: 20.h),
                Row(children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(color: AppTheme.accentLight, borderRadius: BorderRadius.circular(12.r)),
                    child: Icon(Icons.fitness_center_rounded, color: AppTheme.primary, size: 28.w),
                  ),
                  SizedBox(width: 16.w),
                  Text('Log Exercise', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.3)),
                ]),
                SizedBox(height: 24.h),
                Text('EXERCISE TYPE', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 0.8)),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w, runSpacing: 8.h,
                  children: types.map((t) {
                    final sel = selectedType == t['key'];
                    return GestureDetector(
                      onTap: () => setModal(() => selectedType = t['key'] as String),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: sel ? AppTheme.primary : AppTheme.background,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(t['icon'] as IconData, color: sel ? Colors.white : AppTheme.textMuted, size: 18.w),
                          SizedBox(width: 6.w),
                          Text(t['name'] as String, style: TextStyle(color: sel ? Colors.white : AppTheme.textMuted, fontWeight: FontWeight.w600, fontSize: 13.sp)),
                        ]),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20.h),
                _field(nameCtrl,     'Custom Name (Optional)', Icons.edit_rounded,  hint: 'e.g., Morning Run', isNumber: false),
                SizedBox(height: 14.h),
                _field(durationCtrl, 'Duration (minutes)',     Icons.timer_rounded, hint: '30'),
                SizedBox(height: 24.h),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        side: BorderSide(color: AppTheme.border),
                        foregroundColor: AppTheme.textPrimary,
                      ),
                      child: Text('Cancel', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final d = int.tryParse(durationCtrl.text);
                        if (d != null && d > 0) {
                          Navigator.pop(context, {'type': selectedType, 'duration': d, 'name': nameCtrl.text.trim()});
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        backgroundColor: AppTheme.primary, foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                      ),
                      child: Text('Log Exercise', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ]),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );

    if (result != null) {
      final success = await ref.read(activityProvider.notifier).logExercise(
        exerciseType: result['type'],
        duration: result['duration'],
        customName: result['name'].isNotEmpty ? result['name'] : null,
      );
      if (success) {
        final activity = ref.read(activityProvider).todayActivity;
        if (activity != null && mounted) {
          final last = activity.exercises.last;
          ScaffoldMessenger.of(context).showSnackBar(_snackBar(
            '${last.displayName}: ${result['duration']} min, ${last.calories} cal burned!',
            AppTheme.kGoalMet, Icons.check_circle_rounded,
          ));
          if (activity.isExerciseGoalMet) _showGoalSnackbar('Exercise goal completed! 🏋️', AppTheme.primary);
        }
      }
    }
  }

  Future<void> _deleteExercise(String id) async {
    final success = await ref.read(activityProvider.notifier).deleteExercise(id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(_snackBar('Exercise deleted', AppTheme.danger, Icons.delete_rounded));
    }
  }

  Future<void> _updateMeditation() async {
    final todayActivity = ref.read(activityProvider).todayActivity;
    if (todayActivity == null) return;
    final ctrl = TextEditingController(text: todayActivity.meditation.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => _SimpleDialog(
        title: 'Meditation Duration', icon: Icons.self_improvement_rounded,
        controller: ctrl, label: 'Duration (minutes)', isDecimal: false,
        onSave: () => Navigator.of(ctx).pop(int.tryParse(ctrl.text)),
      ),
    );
    if (result != null && result >= 0) {
      final success = await ref.read(activityProvider.notifier).setMeditation(result);
      if (success) {
        final activity = ref.read(activityProvider).todayActivity;
        if (activity != null && activity.isMeditationGoalMet) {
          _showGoalSnackbar('Meditation goal completed! 🧘', AppTheme.primary);
        }
      }
    }
  }

  Future<void> _updateSleep() async {
    final todayActivity = ref.read(activityProvider).todayActivity;
    if (todayActivity == null) return;
    final ctrl = TextEditingController(text: todayActivity.sleepTime.toString());
    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => _SimpleDialog(
        title: 'Sleep Time', icon: Icons.bedtime_rounded,
        controller: ctrl, label: 'Hours (e.g., 7.5)', isDecimal: true,
        onSave: () => Navigator.of(ctx).pop(double.tryParse(ctrl.text)),
      ),
    );
    if (result != null && result >= 0) {
      final success = await ref.read(activityProvider.notifier).setSleepTime(result);
      if (success) {
        final activity = ref.read(activityProvider).todayActivity;
        if (activity != null && activity.isSleepGoalMet) {
          _showGoalSnackbar('Sleep goal completed! 😴', AppTheme.primary);
        }
      }
    }
  }

  void _showGoalSnackbar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(_snackBar(message, color, Icons.celebration_rounded, duration: 3));
  }

  SnackBar _snackBar(String msg, Color color, IconData icon, {int duration = 2}) {
    return SnackBar(
      content: Row(children: [
        Icon(icon, color: Colors.white, size: 20.w),
        SizedBox(width: 12.w),
        Expanded(child: Text(msg, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600))),
      ]),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      margin: EdgeInsets.all(16.w),
      duration: Duration(seconds: duration),
    );
  }

  void _showGoalsDialog(DailyActivity todayActivity) {
    final w = TextEditingController(text: todayActivity.goals.waterIntake.toString());
    final e = TextEditingController(text: todayActivity.goals.exerciseDuration.toString());
    final m = TextEditingController(text: todayActivity.goals.meditation.toString());
    final s = TextEditingController(text: todayActivity.goals.sleepTime.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        backgroundColor: AppTheme.surface,
        title: Text('Update Daily Goals', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _field(w, 'Water Goal (ml)',           Icons.water_drop_rounded),
            SizedBox(height: 12.h),
            _field(e, 'Exercise Goal (minutes)',   Icons.fitness_center_rounded),
            SizedBox(height: 12.h),
            _field(m, 'Meditation Goal (minutes)', Icons.self_improvement_rounded),
            SizedBox(height: 12.h),
            _field(s, 'Sleep Goal (hours)',        Icons.bedtime_rounded, isDecimal: true),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textMuted, fontSize: 14.sp, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              final water    = int.tryParse(w.text);
              final exercise = int.tryParse(e.text);
              final med      = int.tryParse(m.text);
              final sleep    = double.tryParse(s.text);
              if (water != null && exercise != null && med != null && sleep != null) {
                Navigator.pop(ctx);
                await ref.read(activityProvider.notifier).updateDailyGoals(
                  waterIntake:      water,
                  exerciseDuration: exercise,
                  meditation:       med,
                  sleepTime:        sleep,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h), elevation: 0,
            ),
            child: Text('Save', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {String? hint, bool isNumber = true, bool isDecimal = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber
          ? (isDecimal
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.number)
          : TextInputType.text,
      style: TextStyle(fontSize: 15.sp, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label, hintText: hint,
        hintStyle: TextStyle(color: AppTheme.textMuted.withOpacity(0.6)),
        labelStyle: TextStyle(color: AppTheme.textMuted, fontSize: 14.sp),
        floatingLabelStyle: TextStyle(color: AppTheme.primary, fontSize: 13.sp),
        filled: true, fillColor: AppTheme.background,
        prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 20.w),
        border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppTheme.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppTheme.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppTheme.primary, width: 1.5.w)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activityState = ref.watch(activityProvider);
    final todayActivity = activityState.todayActivity;
    final isLoading     = activityState.isLoading;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Daily Activity', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20.sp, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
        actions: [
          IconButton(
            icon: Icon(Icons.analytics_outlined, color: AppTheme.textPrimary, size: 22.w),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityAnalysisScreen())),
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: AppTheme.textPrimary, size: 22.w),
            onPressed: todayActivity != null ? () => _showGoalsDialog(todayActivity) : null,
          ),
        ],
      ),
      body: isLoading && todayActivity == null
          ? Center(child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2.5.w))
          : todayActivity == null
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.error_outline_rounded, size: 60.w, color: AppTheme.border),
                  SizedBox(height: 12.h),
                  Text('Failed to load activity', style: TextStyle(color: AppTheme.textMuted, fontSize: 16.sp, fontWeight: FontWeight.w500)),
                ]))
              : RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: () => ref.read(activityProvider.notifier).loadTodayActivity(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDateCard(todayActivity),
                        SizedBox(height: 16.h),
                        _buildWaterSection(todayActivity),
                        SizedBox(height: 16.h),
                        _buildExerciseSection(todayActivity),
                        if (todayActivity.exercises.isNotEmpty) ...[
                          SizedBox(height: 16.h),
                          _buildExerciseListSection(todayActivity),
                        ],
                        SizedBox(height: 16.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildMeditationSection(todayActivity)),
                            SizedBox(width: 12.w),
                            Expanded(child: _buildSleepSection(todayActivity)),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        _buildSummaryCard(todayActivity),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildDateCard(DailyActivity todayActivity) {
    final now = DateTime.now();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14.r)),
          child: Column(children: [
            Text(now.day.toString(), style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, height: 1)),
            SizedBox(height: 2.h),
            Text(_monthShort(now.month), style: TextStyle(fontSize: 11.sp, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
          ]),
        ),
        SizedBox(width: 16.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Today', style: TextStyle(color: Colors.white70, fontSize: 13.sp, fontWeight: FontWeight.w500)),
          SizedBox(height: 2.h),
          Text(_fullDate(now), style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.2)),
        ])),
        if (todayActivity.areAllGoalsMet)
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
            child: Icon(Icons.emoji_events_rounded, color: AppTheme.kGold, size: 26.w),
          ),
      ]),
    );
  }

  Widget _buildWaterSection(DailyActivity todayActivity) {
    final progress = todayActivity.waterProgress / 100;
    final met = progress >= 1.0;
    return _SectionCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _badge(Icons.water_drop_rounded, AppTheme.primary, AppTheme.accentLight),
          SizedBox(width: 12.w),
          Text('Water Intake', style: _titleStyle),
          const Spacer(),
          Text('${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: met ? AppTheme.kGoalMet : AppTheme.primary)),
        ]),
        SizedBox(height: 16.h),
        RichText(text: TextSpan(children: [
          TextSpan(text: '${todayActivity.waterIntake}ml', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: -0.5, height: 1)),
          TextSpan(text: ' / ${todayActivity.goals.waterIntake}ml', style: TextStyle(fontSize: 16.sp, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
        ])),
        SizedBox(height: 16.h),
        _progressBar(progress, met ? AppTheme.kGoalMet : AppTheme.primary, AppTheme.accentLight),
        SizedBox(height: 16.h),
        Row(children: [
          Expanded(child: _waterBtn(100,  Icons.local_drink_rounded)),
          SizedBox(width: 8.w),
          Expanded(child: _waterBtn(250,  Icons.local_cafe_rounded)),
          SizedBox(width: 8.w),
          Expanded(child: _waterBtn(500,  Icons.emoji_food_beverage_rounded)),
          SizedBox(width: 8.w),
          Expanded(child: _waterBtn(-250, Icons.remove_rounded)),
        ]),
      ]),
    );
  }

  Widget _waterBtn(int amount, IconData icon) {
    final isRemove = amount < 0;
    return ElevatedButton(
      onPressed: () => _updateWater(amount),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentLight,
        foregroundColor: AppTheme.primary,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        elevation: 0,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 18.w),
        SizedBox(height: 4.h),
        Text(isRemove ? '${amount}ml' : '+${amount}ml', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _buildExerciseSection(DailyActivity todayActivity) {
    final progress = todayActivity.exerciseProgress / 100;
    final met = progress >= 1.0;
    return _SectionCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _badge(Icons.fitness_center_rounded, AppTheme.primary, AppTheme.accentLight),
          SizedBox(width: 12.w),
          Text('Exercise', style: _titleStyle),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(color: AppTheme.accentLight, borderRadius: BorderRadius.circular(20.r)),
            child: Text('${todayActivity.caloriesBurned} cal', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppTheme.primary)),
          ),
        ]),
        SizedBox(height: 16.h),
        RichText(text: TextSpan(children: [
          TextSpan(text: '${todayActivity.totalExerciseDuration}min', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: -0.5, height: 1)),
          TextSpan(text: ' / ${todayActivity.goals.exerciseDuration}min', style: TextStyle(fontSize: 16.sp, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
        ])),
        SizedBox(height: 16.h),
        _progressBar(progress, met ? AppTheme.kGoalMet : AppTheme.primary, AppTheme.accentLight),
        SizedBox(height: 16.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _logExercise,
            icon: Icon(Icons.add_rounded, size: 20.w),
            label: Text('Log Exercise', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary, foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              elevation: 0,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildExerciseListSection(DailyActivity todayActivity) {
    return _SectionCard(
      padding: EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 0),
          child: Row(children: [
            Icon(Icons.list_alt_rounded, color: AppTheme.primary, size: 22.w),
            SizedBox(width: 12.w),
            Text('Exercise Log', style: _titleStyle),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(color: AppTheme.accentLight, borderRadius: BorderRadius.circular(8.r)),
              child: Text('${todayActivity.exercises.length}', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 12.sp)),
            ),
          ]),
        ),
        SizedBox(height: 8.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: todayActivity.exercises.length,
          separatorBuilder: (_, __) => Divider(height: 1, color: AppTheme.border),
          itemBuilder: (context, index) {
            final ex = todayActivity.exercises[index];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Row(children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(color: AppTheme.accentLight, borderRadius: BorderRadius.circular(10.r)),
                  child: _exerciseIcon(ex.type),
                ),
                SizedBox(width: 12.w),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(ex.displayName, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.sp, color: AppTheme.textPrimary)),
                  SizedBox(height: 4.h),
                  Text('${_formatTime(ex.timestamp)} · ${ex.duration} min · ${ex.calories} cal',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12.sp)),
                ])),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, color: AppTheme.danger, size: 20.w),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                        backgroundColor: AppTheme.surface,
                        title: Text('Delete Exercise?', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                        content: Text('Remove ${ex.displayName} from your log?', style: TextStyle(fontSize: 15.sp, color: AppTheme.textMuted)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text('Cancel', style: TextStyle(color: AppTheme.textMuted, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
                            child: Text('Delete', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) _deleteExercise(ex.id);
                  },
                ),
              ]),
            );
          },
        ),
        SizedBox(height: 4.h),
      ]),
    );
  }

  Widget _buildMeditationSection(DailyActivity todayActivity) {
    final progress = todayActivity.meditationProgress / 100;
    return GestureDetector(
      onTap: _updateMeditation,
      child: _SectionCard(
        child: Column(children: [
          _badge(Icons.self_improvement_rounded, AppTheme.primary, AppTheme.accentLight),
          SizedBox(height: 12.h),
          Text('${todayActivity.meditation}min', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: -0.5, height: 1)),
          SizedBox(height: 2.h),
          Text('/ ${todayActivity.goals.meditation}min', style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
          SizedBox(height: 10.h),
          _progressBar(progress, progress >= 1.0 ? AppTheme.kGoalMet : AppTheme.primary, AppTheme.accentLight, height: 6),
          SizedBox(height: 10.h),
          Text('Meditation', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        ]),
      ),
    );
  }

  Widget _buildSleepSection(DailyActivity todayActivity) {
    final progress = todayActivity.sleepProgress / 100;
    return GestureDetector(
      onTap: _updateSleep,
      child: _SectionCard(
        child: Column(children: [
          _badge(Icons.bedtime_rounded, AppTheme.primary, AppTheme.accentLight),
          SizedBox(height: 12.h),
          Text('${todayActivity.sleepTime}h', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: -0.5, height: 1)),
          SizedBox(height: 2.h),
          Text('/ ${todayActivity.goals.sleepTime}h', style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
          SizedBox(height: 10.h),
          _progressBar(progress, progress >= 1.0 ? AppTheme.kGoalMet : AppTheme.primary, AppTheme.accentLight, height: 6),
          SizedBox(height: 10.h),
          Text('Sleep', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        ]),
      ),
    );
  }

  Widget _buildSummaryCard(DailyActivity todayActivity) {
    final allMet = todayActivity.areAllGoalsMet;
    final count  = [
      todayActivity.isWaterGoalMet,
      todayActivity.isExerciseGoalMet,
      todayActivity.isMeditationGoalMet,
      todayActivity.isSleepGoalMet,
    ].where((m) => m).length;
    final bg = allMet ? AppTheme.kGoalMet : AppTheme.primary;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [BoxShadow(color: bg.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Icon(allMet ? Icons.celebration_rounded : Icons.trending_up_rounded, size: 48.w, color: Colors.white),
        SizedBox(height: 12.h),
        Text(
          allMet ? 'Perfect Day! 🎉' : 'Keep Going!',
          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
        ),
        SizedBox(height: 6.h),
        Text(
          allMet ? "You've achieved all 4 goals today!" : "You've completed $count out of 4 goals",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w500),
        ),
      ]),
    );
  }

  TextStyle get _titleStyle => TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.2);

  Widget _badge(IconData icon, Color color, Color bg) => Container(
    padding: EdgeInsets.all(10.w),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12.r)),
    child: Icon(icon, color: color, size: 22.w),
  );

  Widget _progressBar(double value, Color color, Color bg, {double height = 10}) => ClipRRect(
    borderRadius: BorderRadius.circular(10.r),
    child: LinearProgressIndicator(
      value: value, minHeight: height.h,
      backgroundColor: bg,
      valueColor: AlwaysStoppedAnimation<Color>(color),
    ),
  );

  Icon _exerciseIcon(String type) {
    const s = 20.0;
    switch (type.toLowerCase()) {
      case 'running':         return Icon(Icons.directions_run_rounded,   color: AppTheme.primary, size: s);
      case 'walking':         return Icon(Icons.directions_walk_rounded,  color: AppTheme.primary, size: s);
      case 'cycling':         return Icon(Icons.directions_bike_rounded,  color: AppTheme.primary, size: s);
      case 'swimming':        return Icon(Icons.pool_rounded,             color: AppTheme.primary, size: s);
      case 'yoga':            return Icon(Icons.self_improvement_rounded, color: AppTheme.primary, size: s);
      case 'weight_training': return Icon(Icons.fitness_center_rounded,  color: AppTheme.primary, size: s);
      case 'hiit':            return Icon(Icons.whatshot_rounded,         color: AppTheme.primary, size: s);
      case 'dancing':         return Icon(Icons.music_note_rounded,       color: AppTheme.primary, size: s);
      default:                return Icon(Icons.fitness_center_rounded,  color: AppTheme.primary, size: s);
    }
  }

  String _formatTime(DateTime t) {
    final h  = t.hour;
    final m  = t.minute.toString().padLeft(2, '0');
    final p  = h >= 12 ? 'PM' : 'AM';
    final dh = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$dh:$m $p';
  }

  String _fullDate(DateTime d) {
    const days   = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]}';
  }

  String _monthShort(int m) {
    const months = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
    return months[m - 1];
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child, this.padding});
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppTheme.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }
}

class _SimpleDialog extends StatelessWidget {
  const _SimpleDialog({
    required this.title,
    required this.icon,
    required this.controller,
    required this.label,
    required this.isDecimal,
    required this.onSave,
  });
  final String title, label;
  final IconData icon;
  final TextEditingController controller;
  final bool isDecimal;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      backgroundColor: AppTheme.surface,
      title: Row(children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(color: AppTheme.accentLight, borderRadius: BorderRadius.circular(8.r)),
          child: Icon(icon, color: AppTheme.primary, size: 20.w),
        ),
        SizedBox(width: 12.w),
        Text(title, style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
      ]),
      content: TextField(
        controller: controller,
        keyboardType: isDecimal
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.number,
        style: TextStyle(fontSize: 15.sp, color: AppTheme.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppTheme.textMuted, fontSize: 14.sp),
          floatingLabelStyle: TextStyle(color: AppTheme.primary, fontSize: 13.sp),
          filled: true, fillColor: AppTheme.background,
          prefixIcon: Icon(Icons.timer_rounded, color: AppTheme.textMuted, size: 20.w),
          border:        OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppTheme.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppTheme.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppTheme.primary, width: 1.5.w)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: AppTheme.textMuted, fontSize: 14.sp, fontWeight: FontWeight.w600)),
        ),
        ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h), elevation: 0,
          ),
          child: Text('Save', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}