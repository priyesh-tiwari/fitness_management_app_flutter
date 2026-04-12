import 'package:fitness_management_app/features/notification/services/notification_api_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';

class NotificationState {
  final List<AppNotification> notifications;
  final bool isLoading;
  final String? error;
  final int unreadCount;

  NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    List<AppNotification>? notifications,
    bool? isLoading,
    String? error,
    int? unreadCount,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(NotificationState()) {
    _loadNotifications();
  }

  final _api = NotificationApiService();

  Future<void> _loadNotifications() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _api.getNotifications();
      final notifications = data.map((item) => AppNotification.fromJson({
        ...item,
        'id': item['_id'],
        'timestamp': item['createdAt'] is String
    ? item['createdAt']
    : item['createdAt']?.toString(),

      })).toList();

      final unreadCount = notifications.where((n) => !n.isRead).length;
      state = state.copyWith(
        notifications: notifications,
        isLoading: false,
        unreadCount: unreadCount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load notifications',
      );
    }
  }

  // Called when FCM delivers a foreground message — optimistic UI only
  // Backend already saved it via saveNotificationToDB in notification_service.js
  Future<void> addNotification(AppNotification notification) async {
    final updated = [notification, ...state.notifications];
    final unreadCount = updated.where((n) => !n.isRead).length;
    state = state.copyWith(notifications: updated, unreadCount: unreadCount);
  }

  Future<void> markAsRead(String notificationId) async {
    await _api.markAsRead(notificationId);
    final updated = state.notifications
        .map((n) => n.id == notificationId ? n.copyWith(isRead: true) : n)
        .toList();
    final unreadCount = updated.where((n) => !n.isRead).length;
    state = state.copyWith(notifications: updated, unreadCount: unreadCount);
  }

  Future<void> markAllAsRead() async {
    await _api.markAllAsRead();
    final updated = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(notifications: updated, unreadCount: 0);
  }

  Future<void> deleteNotification(String notificationId) async {
    await _api.deleteNotification(notificationId);
    final updated = state.notifications.where((n) => n.id != notificationId).toList();
    final unreadCount = updated.where((n) => !n.isRead).length;
    state = state.copyWith(notifications: updated, unreadCount: unreadCount);
  }

  Future<void> clearAll() async {
    await _api.clearAll();
    state = state.copyWith(notifications: [], unreadCount: 0);
  }

  Future<void> refresh() async {
    await _loadNotifications();
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});