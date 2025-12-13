import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

/// Service for managing local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Notification channel IDs
  static const String _timerChannelId = 'app_timer_channel';
  static const String _reminderChannelId = 'screen_time_reminder_channel';

  /// Notification IDs
  static const int _timerNotificationBaseId = 1000;
  static const int _reminderNotificationBaseId = 2000;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Android initialization
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    await _createNotificationChannels();

    _isInitialized = true;
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // App Timer channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _timerChannelId,
          'App Timers',
          description: 'Notifications for app usage limits',
          importance: Importance.high,
        ),
      );

      // Screen Time Reminder channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _reminderChannelId,
          'Screen Time Reminders',
          description: 'Notifications for screen time reminders',
          importance: Importance.high,
        ),
      );
    }
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }

    return true; // iOS handles permissions during initialization
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Can navigate to specific screen based on payload
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Show app timer limit exceeded notification
  Future<void> showAppTimerNotification({
    required String appName,
    required int limitMinutes,
  }) async {
    final notificationId = _timerNotificationBaseId + appName.hashCode.abs() % 1000;

    await _notifications.show(
      notificationId,
      '⏱️ Süre Doldu',
      '$appName için günlük $limitMinutes dakika limitiniz doldu',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _timerChannelId,
          'App Timers',
          channelDescription: 'Notifications for app usage limits',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF4285F4),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'app_timer:$appName',
    );
  }

  /// Show screen time reminder notification
  Future<void> showScreenTimeReminderNotification({
    required int thresholdMinutes,
    required int actualMinutes,
  }) async {
    final hours = actualMinutes ~/ 60;
    final mins = actualMinutes % 60;
    final timeStr = hours > 0 ? '${hours}s ${mins}dk' : '${mins}dk';

    await _notifications.show(
      _reminderNotificationBaseId,
      '📱 Ekran Süresi Uyarısı',
      'Bugün $timeStr ekran kullandınız (Eşik: $thresholdMinutes dk)',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _reminderChannelId,
          'Screen Time Reminders',
          channelDescription: 'Notifications for screen time reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFFEA4335),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'screen_time_reminder',
    );
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }
}
