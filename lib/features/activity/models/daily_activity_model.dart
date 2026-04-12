class DailyActivity {
  final String id;
  final String userId;
  final DateTime date;
  final int waterIntake;
  final int meditation;
  final double sleepTime;
  final int caloriesBurned;
  final List<Exercise> exercises;
  final Goals goals;
  final GoalProgress? goalProgress;
  final DateTime createdAt;

  DailyActivity({
    required this.id,
    required this.userId,
    required this.date,
    required this.waterIntake,
    required this.meditation,
    required this.sleepTime,
    required this.goals,
    required this.createdAt,
    required this.caloriesBurned,
    required this.exercises,
    this.goalProgress,
  });

  factory DailyActivity.fromJson(Map<String, dynamic> json) {
    return DailyActivity(
      id: json['_id'] ?? '',
      userId: json['user'] ?? '',
      // FIX 1: tryParse + null guard — prevents crash if date field is null/malformed
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      waterIntake: json['waterIntake'] ?? 0,
      meditation: json['meditation'] ?? 0,
      sleepTime: (json['sleepTime'] ?? 0).toDouble(),
      caloriesBurned: json['caloriesBurned'] ?? 0,
      exercises: (json['exercises'] as List?)
          ?.map((e) => Exercise.fromJson(e))
          .toList() ?? [],
      goals: Goals.fromJson(json['goals'] ?? {}),
      goalProgress: json['goalProgress'] != null
          ? GoalProgress.fromJson(json['goalProgress'])
          : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  int get totalExerciseDuration => exercises.fold(0, (sum, ex) => sum + ex.duration);

  double get waterProgress =>
      goals.waterIntake > 0 ? (waterIntake / goals.waterIntake * 100).clamp(0, 100) : 0;

  double get exerciseProgress =>
      goals.exerciseDuration > 0 ? (totalExerciseDuration / goals.exerciseDuration * 100).clamp(0, 100) : 0;

  double get meditationProgress =>
      goals.meditation > 0 ? (meditation / goals.meditation * 100).clamp(0, 100) : 0;

  double get sleepProgress =>
      goals.sleepTime > 0 ? (sleepTime / goals.sleepTime * 100).clamp(0, 100) : 0;

  bool get isWaterGoalMet => waterIntake >= goals.waterIntake;
  bool get isExerciseGoalMet => totalExerciseDuration >= goals.exerciseDuration;
  bool get isMeditationGoalMet => meditation >= goals.meditation;
  bool get isSleepGoalMet => sleepTime >= goals.sleepTime;
  bool get areAllGoalsMet =>
      isWaterGoalMet && isExerciseGoalMet && isMeditationGoalMet && isSleepGoalMet;
}

class Exercise {
  final String id;
  final String type;
  final String? customName;
  final int duration;
  final int calories;
  final DateTime timestamp;

  Exercise({
    required this.id,
    required this.type,
    this.customName,
    required this.duration,
    required this.calories,
    required this.timestamp,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['_id'] ?? '',
      type: json['type'] ?? '',
      customName: json['customName'],
      duration: json['duration'] ?? 0,
      // FIX 2: .toInt() — backend calculateCalories returns a decimal (e.g. 150.7)
      // Without this Dart throws a type cast error at runtime
      calories: (json['calories'] ?? 0).toInt(),
      // Also applied tryParse here for consistency
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  String get displayName => customName ?? _formatType(type);

  String _formatType(String type) {
    return type.split('_').map((word) =>
        word[0].toUpperCase() + word.substring(1)).join(' ');
  }
}

class Goals {
  final int waterIntake;
  final int exerciseDuration;
  final int meditation;
  final double sleepTime;

  Goals({
    required this.waterIntake,
    required this.exerciseDuration,
    required this.meditation,
    required this.sleepTime,
  });

  factory Goals.fromJson(Map<String, dynamic> json) {
    return Goals(
      waterIntake: json['waterIntake'] ?? 2000,
      exerciseDuration: json['exerciseDuration'] ?? 30,
      meditation: json['meditation'] ?? 15,
      sleepTime: (json['sleepTime'] ?? 7).toDouble(),
    );
  }
}

class GoalProgress {
  final GoalProgressItem water;
  final GoalProgressItem exercise;
  final GoalProgressItem meditation;
  final GoalProgressItem sleep;

  GoalProgress({
    required this.water,
    required this.exercise,
    required this.meditation,
    required this.sleep,
  });

  factory GoalProgress.fromJson(Map<String, dynamic> json) {
    return GoalProgress(
      water:      GoalProgressItem.fromJson(json['water']      ?? {}),
      exercise:   GoalProgressItem.fromJson(json['exercise']   ?? {}),
      meditation: GoalProgressItem.fromJson(json['meditation'] ?? {}),
      sleep:      GoalProgressItem.fromJson(json['sleep']      ?? {}),
    );
  }
}

class GoalProgressItem {
  final num current;
  final num goal;
  final int percentage;

  GoalProgressItem({
    required this.current,
    required this.goal,
    required this.percentage,
  });

  factory GoalProgressItem.fromJson(Map<String, dynamic> json) {
    return GoalProgressItem(
      current:    json['current']    ?? 0,
      goal:       json['goal']       ?? 0,
      percentage: json['percentage'] ?? 0,
    );
  }
}

class WeeklyAnalysis {
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final List<DailyActivity> activities;
  final Totals totals;
  final Averages averages;
  final int totalDays;
  final GoalsAchieved goalsAchieved;
  final int streak;

  WeeklyAnalysis({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.activities,
    required this.totals,
    required this.averages,
    required this.totalDays,
    required this.goalsAchieved,
    required this.streak,
  });

  factory WeeklyAnalysis.fromJson(Map<String, dynamic> json) {
    return WeeklyAnalysis(
      period:    json['period'] ?? 'week',
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate:   DateTime.tryParse(json['endDate']   ?? '') ?? DateTime.now(),
      activities: (json['activities'] as List?)
          ?.map((a) => DailyActivity.fromJson(a))
          .toList() ?? [],
      totals:       Totals.fromJson(json['totals']           ?? {}),
      averages:     Averages.fromJson(json['averages']       ?? {}),
      totalDays:    json['totalDays']    ?? 0,
      goalsAchieved: GoalsAchieved.fromJson(json['goalsAchieved'] ?? {}),
      streak:       json['streak']       ?? 0,
    );
  }
}

class MonthlyAnalysis {
  final String month;
  final DateTime startDate;
  final DateTime endDate;
  final List<DailyActivity> activities;
  final Totals totals;
  final Averages averages;
  final int totalDays;
  final int perfectDays;
  final GoalsAchieved goalsAchieved;
  final int completionRate;

  MonthlyAnalysis({
    required this.month,
    required this.startDate,
    required this.endDate,
    required this.activities,
    required this.totals,
    required this.averages,
    required this.totalDays,
    required this.perfectDays,
    required this.goalsAchieved,
    required this.completionRate,
  });

  factory MonthlyAnalysis.fromJson(Map<String, dynamic> json) {
    return MonthlyAnalysis(
      month:      json['month'] ?? '',
      startDate:  DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate:    DateTime.tryParse(json['endDate']   ?? '') ?? DateTime.now(),
      activities: (json['activities'] as List?)
          ?.map((a) => DailyActivity.fromJson(a))
          .toList() ?? [],
      totals:        Totals.fromJson(json['totals']           ?? {}),
      averages:      Averages.fromJson(json['averages']       ?? {}),
      totalDays:     json['totalDays']     ?? 0,
      perfectDays:   json['perfectDays']   ?? 0,
      goalsAchieved: GoalsAchieved.fromJson(json['goalsAchieved'] ?? {}),
      completionRate: json['completionRate'] ?? 0,
    );
  }
}

class Totals {
  final int water;
  final int exercise;
  final int meditation;
  final double sleep;
  final int calories;

  Totals({
    required this.water,
    required this.exercise,
    required this.meditation,
    required this.sleep,
    required this.calories,
  });

  factory Totals.fromJson(Map<String, dynamic> json) {
    return Totals(
      water:      json['water']      ?? 0,
      exercise:   json['exercise']   ?? 0,
      meditation: json['meditation'] ?? 0,
      sleep:      (json['sleep']     ?? 0).toDouble(),
      calories:   json['calories']   ?? 0,
    );
  }
}

class Averages {
  final int water;
  final int exercise;
  final int meditation;
  final double sleep;
  final int calories;

  Averages({
    required this.water,
    required this.exercise,
    required this.meditation,
    required this.sleep,
    required this.calories,
  });

  factory Averages.fromJson(Map<String, dynamic> json) {
    return Averages(
      water:      json['water']      ?? 0,
      exercise:   json['exercise']   ?? 0,
      meditation: json['meditation'] ?? 0,
      // Backend returns .toFixed(1) which is a JS string e.g. "7.5" — must handle both
      sleep: json['sleep'] is String
          ? double.parse(json['sleep'])
          : (json['sleep'] ?? 0).toDouble(),
      calories: json['calories'] ?? 0,
    );
  }
}

class GoalsAchieved {
  final int water;
  final int exercise;
  final int meditation;
  final int sleep;

  GoalsAchieved({
    required this.water,
    required this.exercise,
    required this.meditation,
    required this.sleep,
  });

  factory GoalsAchieved.fromJson(Map<String, dynamic> json) {
    return GoalsAchieved(
      water:      json['water']      ?? 0,
      exercise:   json['exercise']   ?? 0,
      meditation: json['meditation'] ?? 0,
      sleep:      json['sleep']      ?? 0,
    );
  }
}