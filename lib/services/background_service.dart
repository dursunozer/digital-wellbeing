import 'package:workmanager/workmanager.dart';
import 'package:app_usage/app_usage.dart' as app_usage;
import '../models/app_usage_info.dart';
import '../models/daily_usage.dart';
import 'usage_database.dart';

/// Unique task name for periodic usage saving
const String kSaveUsageTask = 'com.digitalwellbeing.saveUsageTask';

/// Background callback dispatcher - must be top-level function
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case kSaveUsageTask:
          await _saveCurrentUsageData();
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
}
