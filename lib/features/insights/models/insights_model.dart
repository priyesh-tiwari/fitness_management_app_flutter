class InsightsResponse {
  final bool success;
  final InsightsData data;

  InsightsResponse({
    required this.success,
    required this.data,
  });

  factory InsightsResponse.fromJson(Map<String, dynamic> json) {
    return InsightsResponse(
      success: json['success'] ?? false,
      data: InsightsData.fromJson(json['data'] ?? {}),
    );
  }
}

class InsightsData {
  final Insights insights;
  final DateTime generatedAt;
  final DataAnalyzed dataAnalyzed;

  InsightsData({
    required this.insights,
    required this.generatedAt,
    required this.dataAnalyzed,
  });

  factory InsightsData.fromJson(Map<String, dynamic> json) {
    return InsightsData(
      insights: Insights.fromJson(json['insights'] ?? {}),
      generatedAt: json['generatedAt'] != null
          ? DateTime.parse(json['generatedAt'])
          : DateTime.now(),
      dataAnalyzed: DataAnalyzed.fromJson(json['dataAnalyzed'] ?? {}),
    );
  }
}

class Insights {
  final String summary;
  final List<String> strengths;
  final List<String> improvements;
  final List<String> recommendations;

  Insights({
    required this.summary,
    required this.strengths,
    required this.improvements,
    required this.recommendations,
  });

  factory Insights.fromJson(Map<String, dynamic> json) {
    return Insights(
      summary: json['summary'] ?? '',
      strengths: (json['strengths'] as List?)?.cast<String>() ?? [],
      improvements: (json['improvements'] as List?)?.cast<String>() ?? [],
      recommendations: (json['recommendations'] as List?)?.cast<String>() ?? [],
    );
  }
}

class DataAnalyzed {
  final int attendanceRate;
  final int currentStreak;
  final int daysLogged;
  final int daysAllGoalsAchieved;
  final int daysAnalyzed;

  DataAnalyzed({
    required this.attendanceRate,
    required this.currentStreak,
    required this.daysLogged,
    required this.daysAllGoalsAchieved,
    required this.daysAnalyzed,
  });

  factory DataAnalyzed.fromJson(Map<String, dynamic> json) {
    return DataAnalyzed(
      attendanceRate: json['attendanceRate'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      daysLogged: json['daysLogged'] ?? 0,
      daysAllGoalsAchieved: json['daysAllGoalsAchieved'] ?? 0,
      daysAnalyzed: json['daysAnalyzed'] ?? 30,
    );
  }
}