import 'package:fitness_management_app/config/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../providers/notification_provider.dart';
import '../models/notification_model.dart';

// ── Pure utility ──────────────────────────────────────────────────────────────
String _formatTimestamp(DateTime timestamp) {
  final diff = DateTime.now().difference(timestamp);
  if (diff.inMinutes < 1)  return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours   < 24) return '${diff.inHours}h ago';
  if (diff.inDays   == 1)  return 'Yesterday';
  if (diff.inDays    < 7)  return '${diff.inDays}d ago';
  return DateFormat('MMM dd').format(timestamp);
}

// ─────────────────────────────────────────────────────────────────────────────
// NotificationsScreen
// ─────────────────────────────────────────────────────────────────────────────
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(notificationProvider.notifier).refresh());
  }

  // ── Handlers ────────────────────────────────────────────────

  Future<void> _onMarkAllRead() async {
    await ref.read(notificationProvider.notifier).markAllAsRead();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All marked as read')),
    );
  }

  Future<void> _onClearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        title: Text(
          'Clear All Notifications',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17.sp, color: AppTheme.textPrimary),
        ),
        content: Text(
          'Are you sure you want to clear all notifications?',
          style: TextStyle(fontSize: 14.sp, color: AppTheme.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear All', style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;
    await ref.read(notificationProvider.notifier).clearAll();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications cleared')),
    );
  }

  Future<void> _onDismiss(String id) async {
    await ref.read(notificationProvider.notifier).deleteNotification(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification deleted')),
    );
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider);
    final hasNotifications  = notificationState.notifications.isNotEmpty;

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
        title: Text(
          'Notifications',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20.sp, fontWeight: FontWeight.w700, letterSpacing: -0.3),
        ),
        actions: [
          if (hasNotifications) _buildOverflowMenu(),
          SizedBox(width: 4.w),
        ],
      ),
      body: notificationState.isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2.5.w))
          : hasNotifications
              ? RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: () => ref.read(notificationProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    itemCount: notificationState.notifications.length,
                    itemBuilder: (_, index) {
                      final notification = notificationState.notifications[index];
                      return _NotificationCard(
                        notification: notification,
                        onTap: () => ref.read(notificationProvider.notifier).markAsRead(notification.id),
                        onDismiss: () => _onDismiss(notification.id),
                      );
                    },
                  ),
                )
              : _buildEmptyState(),
    );
  }

  Widget _buildOverflowMenu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz_rounded, color: AppTheme.textPrimary, size: 22.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      onSelected: (value) {
        if (value == 'mark_all_read') _onMarkAllRead();
        if (value == 'clear_all')     _onClearAll();
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'mark_all_read',
          child: Row(children: [
            Icon(Icons.done_all_rounded, size: 18.w, color: AppTheme.textPrimary),
            SizedBox(width: 12.w),
            Text('Mark all as read', style: TextStyle(fontSize: 14.sp, color: AppTheme.textPrimary)),
          ]),
        ),
        PopupMenuItem(
          value: 'clear_all',
          child: Row(children: [
            Icon(Icons.delete_outline_rounded, size: 18.w, color: AppTheme.danger),
            SizedBox(width: 12.w),
            Text('Clear all', style: TextStyle(fontSize: 14.sp, color: AppTheme.danger)),
          ]),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 60.w, color: AppTheme.border),
          SizedBox(height: 12.h),
          Text('No Notifications', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
          SizedBox(height: 4.h),
          Text("You're all caught up!", style: TextStyle(fontSize: 13.sp, color: AppTheme.textMuted)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _NotificationCard
// ─────────────────────────────────────────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final (bgColor, accentColor) =
        AppTheme.notificationTypeColors[notification.getColorType()] ??
        (AppTheme.background, AppTheme.textMuted);
    final isUnread = !notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(color: AppTheme.danger, borderRadius: BorderRadius.circular(14.r)),
        child: Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22.w),
      ),
      onDismissed: (_) => onDismiss(),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isUnread ? accentColor.withOpacity(0.4) : AppTheme.border,
            width: isUnread ? 1.5 : 1,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12.r)),
                  alignment: Alignment.center,
                  child: Text(notification.getIcon(), style: TextStyle(fontSize: 22.sp)),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          if (isUnread) ...[
                            SizedBox(width: 8.w),
                            Container(
                              width: 7.w, height: 7.w,
                              decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(notification.body, style: TextStyle(fontSize: 13.sp, color: AppTheme.textMuted, height: 1.4)),
                      SizedBox(height: 6.h),
                      Text(_formatTimestamp(notification.timestamp), style: TextStyle(fontSize: 11.sp, color: AppTheme.textMuted.withOpacity(0.7))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}