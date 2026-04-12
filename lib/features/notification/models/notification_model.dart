// lib/features/notifications/models/notification_model.dart

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? 'general',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'data': data,
    };
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }

  // Get icon based on notification type
  String getIcon() {
    switch (type) {
      case 'water_goal_completed':
      case 'activity_reminder_water':
        return '💧';
      case 'exercise_goal_completed':
      case 'activity_reminder_exercise':
        return '🏋️';
      case 'meditation_goal_completed':
      case 'activity_reminder_meditation':
        return '🧘';
      case 'sleep_goal_completed':
      case 'activity_reminder_sleep':
        return '😴';
      case 'all_goals_completed':
      case 'goal_completed':
        return '🎉';
      case 'motivation':
        return '🔥';
      case 'weekly_summary':
        return '📊';
      case 'workout_reminder':
      case 'progress_reminder':
        return '⏰';
      default:
        return '🔔';
    }
  }

  // Get color based on notification type
  String getColorType() {
    switch (type) {
      case 'water_goal_completed':
      case 'activity_reminder_water':
        return 'blue';
      case 'exercise_goal_completed':
      case 'activity_reminder_exercise':
        return 'orange';
      case 'meditation_goal_completed':
      case 'activity_reminder_meditation':
        return 'purple';
      case 'sleep_goal_completed':
      case 'activity_reminder_sleep':
        return 'indigo';
      case 'all_goals_completed':
      case 'goal_completed':
        return 'green';
      case 'motivation':
        return 'red';
      case 'weekly_summary':
        return 'teal';
      default:
        return 'grey';
    }
  }
}