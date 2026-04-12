// lib/services/fcm_service.dart

import 'dart:ui';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fitness_management_app/features/notification/services/notification_api_services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fitness_management_app/features/notification/models/notification_model.dart';
import 'package:fitness_management_app/features/notification/providers/notification_provider.dart';


// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.messageId}');
}

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final Ref ref;

  FCMService(this.ref);

  // Initialize FCM
  Future<void> initialize() async {
    // Request permission for iOS
    await _requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Get FCM token
    final token = await _messaging.getToken();
    print('FCM Token: $token');

    // ✅ SEND TOKEN TO BACKEND
    await _sendTokenToBackend(token);

    // ✅ HANDLE TOKEN REFRESH
    _messaging.onTokenRefresh.listen((newToken) async {
      print('FCM Token refreshed: $newToken');
      await _sendTokenToBackend(newToken);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages (when app is in background but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check if app was opened from a notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  // ✅ SEND FCM TOKEN TO BACKEND
// ✅ SEND TOKEN TO BACKEND
Future<void> _sendTokenToBackend(String? token) async {
  if (token == null) {
    print('❌ FCM Token is null, cannot send to backend');
    return;
  }
  
  print('🔔 Sending FCM token to backend: $token');
  final result = await NotificationApiService().saveFCMToken(token);
  print('🔔 FCM token save result: $result');
}

  // Request notification permission
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined notification permission');
    }
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    const androidChannel = AndroidNotificationChannel(
      'daily_activity',
      'Daily Activity Notifications',
      description: 'Notifications for daily activity goals and reminders',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  // Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground message received: ${message.messageId}');

    // Add to notification list
    await _addNotificationToList(message);

    // Show local notification
    await _showLocalNotification(message);
  }

  // Handle message opened app
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Notification opened: ${message.messageId}');
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
  }

  // Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'daily_activity',
      'Daily Activity Notifications',
      channelDescription: 'Notifications for daily activity goals and reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF4CAF50),
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      Random().nextInt(100000),
      notification.title,
      notification.body,
      details,
      payload: message.messageId,
    );
  }

  // Add notification to list in app
  Future<void> _addNotificationToList(RemoteMessage message) async {
    final notification = AppNotification(
      id: message.messageId ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? '',
      type: message.data['type'] ?? 'general',
      timestamp: DateTime.now(),
      isRead: false,
      data: message.data,
    );

    await ref.read(notificationProvider.notifier).addNotification(notification);
  }

  // Get FCM token
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}

// Provider for FCM Service
final fcmServiceProvider = Provider<FCMService>((ref) {
  return FCMService(ref);
});
