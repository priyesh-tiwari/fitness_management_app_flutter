import 'package:fitness_management_app/features/activity/models/daily_activity_model.dart';
import 'package:fitness_management_app/features/activity/services/activity_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── State ─────────────────────────────────────────────────────────────────────
class ActivityState {
  final bool isLoading;
  final DailyActivity? todayActivity;
  final String? error;

  ActivityState({
    this.isLoading = false,
    this.todayActivity,
    this.error,
  });

  ActivityState copyWith({
    bool? isLoading,
    DailyActivity? todayActivity,
    String? error,
  }) {
    return ActivityState(
      isLoading: isLoading ?? this.isLoading,
      todayActivity: todayActivity ?? this.todayActivity,
      error: error,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────
class ActivityNotifier extends StateNotifier<ActivityState> {
  final DailyActivityService _service = DailyActivityService();

  ActivityNotifier() : super(ActivityState()) {
    loadTodayActivity();
  }

  Future<void> loadTodayActivity() async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await _service.getTodayActivity();
    if (response['success'] == true && response['data'] != null) {
      state = state.copyWith(
        isLoading: false,
        todayActivity: DailyActivity.fromJson(response['data']),
      );
    } else {
      state = state.copyWith(isLoading: false, error: 'Failed to load activity');
    }
  }

  Future<bool> updateWater(int amount) async {
    final response = await _service.updateWater(amount);
    if (response['success'] == true && response['data'] != null) {
      state = state.copyWith(
        todayActivity: DailyActivity.fromJson(response['data']),
      );
      return true;
    }
    return false;
  }

  Future<bool> logExercise({
    required String exerciseType,
    required int duration,
    String? customName,
  }) async {
    final response = await _service.logExercise(
      exerciseType: exerciseType,
      duration: duration,
      customName: customName,
    );
    if (response['success'] == true && response['data'] != null) {
      state = state.copyWith(
        todayActivity: DailyActivity.fromJson(response['data']),
      );
      return true;
    }
    return false;
  }

  Future<bool> deleteExercise(String exerciseId) async {
    final response = await _service.deleteExercise(exerciseId);
    if (response['success'] == true && response['data'] != null) {
      state = state.copyWith(
        todayActivity: DailyActivity.fromJson(response['data']),
      );
      return true;
    }
    return false;
  }

  Future<bool> setMeditation(int duration) async {
    final response = await _service.setMeditation(duration);
    if (response['success'] == true && response['data'] != null) {
      state = state.copyWith(
        todayActivity: DailyActivity.fromJson(response['data']),
      );
      return true;
    }
    return false;
  }

  Future<bool> setSleepTime(double hours) async {
    final response = await _service.setSleepTime(hours);
    if (response['success'] == true && response['data'] != null) {
      state = state.copyWith(
        todayActivity: DailyActivity.fromJson(response['data']),
      );
      return true;
    }
    return false;
  }

  Future<void> updateDailyGoals({
    int? waterIntake,
    int? exerciseDuration,
    int? meditation,
    double? sleepTime,
  }) async {
    await _service.updateDailyGoals(
      waterIntake: waterIntake,
      exerciseDuration: exerciseDuration,
      meditation: meditation,
      sleepTime: sleepTime,
    );
    await loadTodayActivity();
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────
final activityProvider =
    StateNotifierProvider<ActivityNotifier, ActivityState>((ref) {
  return ActivityNotifier();
});