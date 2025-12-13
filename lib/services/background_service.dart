import 'package:workmanager/workmanager.dart';
import 'package:app_usage/app_usage.dart' as app_usage;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_usage_info.dart';
import '../models/daily_usage.dart';
import '../models/feature_settings.dart';
import 'usage_database.dart';
import 'notification_service.dart';

/// Unique task name for periodic usage saving
const String kSaveUsageTask = 'com.digitalwellbeing.saveUsageTask';

/// Preference keys for tracking sent notifications
const String _notifiedTimersKey = 'notified_timers_today';
const String _notifiedRemindersKey = 'notified_reminders_today';
const String _lastNotificationDateKey = 'last_notification_date';

/// Background callback dispatcher - must be top-level function
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case kSaveUsageTask:
          await _saveCurrentUsageData();
          await _checkLimitsAndNotify();
          break;
      }
      return true;
    } catch (e) {
      print('Background task error: $e');
      return false;
    }
  });
}

/// Save current usage data to database
Future<void> _saveCurrentUsageData() async {
  try {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day); // Today 00:00
    
    // Fetch usage from Android API
    final appUsage = app_usage.AppUsage();
    final usageList = await appUsage.getAppUsage(startDate, now);
    
    // Convert to our model
    final apps = usageList.map((usage) => AppUsageInfo(
      packageName: usage.packageName,
      appName: usage.appName,
      appIcon: null, // Icons not available in background
      usageDuration: usage.usage,
    )).toList();
    
    // Calculate total screen time
    final totalTime = apps.fold<Duration>(
      Duration.zero,
      (sum, app) => sum + app.usageDuration,
    );
    
    // Save to database
    final db = UsageDatabase();
    final dailyUsage = DailyUsage(
      date: now,
      totalScreenTime: totalTime,
      unlockCount: 0,
      notificationCount: 0,
      apps: apps,
    );
    await db.saveDailyUsage(dailyUsage);
    
    print('Background: Saved usage data at ${now.hour}:${now.minute}');
  } catch (e) {
    print('Background save error: $e');
  }
}

/// Check app timer limits and screen time reminders, send notifications if needed
Future<void> _checkLimitsAndNotify() async {
  try {
    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    // Initialize notification service
    final notificationService = NotificationService();
    await notificationService.initialize();
    
    // Get preferences to track which notifications we've already sent today
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString(_lastNotificationDateKey) ?? '';
    
    // Reset notification tracking if it's a new day
    if (lastDate != today) {
      await prefs.setStringList(_notifiedTimersKey, []);
      await prefs.setStringList(_notifiedRemindersKey, []);
      await prefs.setString(_lastNotificationDateKey, today);
    }
    
    final notifiedTimers = prefs.getStringList(_notifiedTimersKey) ?? [];
    final notifiedReminders = prefs.getStringList(_notifiedRemindersKey) ?? [];
    
    final db = UsageDatabase();
    
    // Get current usage
    final startDate = DateTime(now.year, now.month, now.day);
    final appUsage = app_usage.AppUsage();
    final usageList = await appUsage.getAppUsage(startDate, now);
    
    // Build usage map
    final usageMap = <String, Duration>{};
    var totalScreenTime = Duration.zero;
    for (final usage in usageList) {
      usageMap[usage.packageName] = usage.usage;
      totalScreenTime += usage.usage;
    }
    
    // Check app timers
    final timers = await db.getAppTimers();
    for (final timer in timers) {
      if (!timer.isEnabled) continue;
      
      final usage = usageMap[timer.packageName] ?? Duration.zero;
      
      // Check if limit exceeded and not already notified
      if (usage >= timer.dailyLimit && !notifiedTimers.contains(timer.packageName)) {
        await notificationService.showAppTimerNotification(
          appName: timer.appName,
          limitMinutes: timer.dailyLimit.inMinutes,
        );
        
        // Mark as notified
        notifiedTimers.add(timer.packageName);
        await prefs.setStringList(_notifiedTimersKey, notifiedTimers);
        
        print('Background: Sent timer notification for ${timer.appName}');
      }
    }
    
    // Check screen time reminders
    final reminders = await db.getScreenTimeReminders();
    for (final reminder in reminders) {
      if (!reminder.isEnabled) continue;
      
      final thresholdDuration = reminder.threshold;
      final reminderId = reminder.id.toString();
      
      // Check if threshold exceeded and not already notified
      if (totalScreenTime >= thresholdDuration && !notifiedReminders.contains(reminderId)) {
        await notificationService.showScreenTimeReminderNotification(
          thresholdMinutes: reminder.threshold.inMinutes,
          actualMinutes: totalScreenTime.inMinutes,
        );
        
        // Mark as notified
        notifiedReminders.add(reminderId);
        await prefs.setStringList(_notifiedRemindersKey, notifiedReminders);
        
        print('Background: Sent reminder notification for ${reminder.threshold.inMinutes} minutes');
      }
    }
  } catch (e) {
    print('Background notification check error: $e');
  }
}

/// Initialize background service
class BackgroundService {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false, // Set to true for debugging
    );
  }
  
  /// Register periodic task to save usage data
  static Future<void> registerPeriodicTask() async {
    // Cancel any existing task first
    await Workmanager().cancelByUniqueName(kSaveUsageTask);
    
    // Register periodic task - runs approximately every 15 minutes
    // (Android enforces minimum 15 min interval)
    await Workmanager().registerPeriodicTask(
      kSaveUsageTask,
      kSaveUsageTask,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
    
    print('Background service: Periodic task registered');
  }
  
  /// Save usage data immediately (for manual trigger)
  static Future<void> saveNow() async {
    await _saveCurrentUsageData();
  }
  
  /// Check limits and send notifications (for manual trigger)
  static Future<void> checkLimitsNow() async {
    await _checkLimitsAndNotify();
  }
}
