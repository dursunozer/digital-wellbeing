import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_usage_info.dart';
import '../models/feature_settings.dart';
import '../models/daily_usage.dart';
import '../services/usage_service.dart';
import '../services/preferences_service.dart';
import '../services/usage_database.dart';

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService();
});

final usageServiceProvider = Provider<UsageService>((ref) {
  final prefsService = ref.watch(preferencesServiceProvider);
  return UsageService(prefsService);
});

final usageDatabaseProvider = Provider<UsageDatabase>((ref) {
  return UsageDatabase();
});

final permissionStatusProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(usageServiceProvider);
  return await service.isPermissionGranted();
});

final appUsageProvider = FutureProvider<List<AppUsageInfo>>((ref) async {
  final service = ref.watch(usageServiceProvider);
  final prefsService = ref.watch(preferencesServiceProvider);
  final db = ref.watch(usageDatabaseProvider);
  
  // Check if reset timestamp exists and if it's from a previous day
  final resetTimestamp = await prefsService.getResetTimestamp();
  final now = DateTime.now();
  
  if (resetTimestamp != null) {
    // If reset was on a different day (day changed at midnight), clear it
    if (resetTimestamp.day != now.day ||
        resetTimestamp.month != now.month ||
        resetTimestamp.year != now.year) {
      await prefsService.clearResetTimestamp();
    }
  }
  
  final isNewDay = await prefsService.isNewDay();
  
  if (isNewDay) {
    await prefsService.clearResetTimestamp();
    await prefsService.setLastFetchDate(DateTime.now());
  }
  
  // Fetch and save missing days from past week
  await _fetchAndSaveMissingDays(service, db);
  
  final apps = await service.fetchUsageData();
  
  // Save today's usage to database for history
  final totalTime = service.calculateTotalScreenTime(apps);
  final dailyUsage = DailyUsage(
    date: DateTime.now(),
    totalScreenTime: totalTime,
    unlockCount: 0,
    notificationCount: 0,
    apps: apps,
  );
  await db.saveDailyUsage(dailyUsage);
  
  return apps;
});

/// Fetch and save missing days from the past week
Future<void> _fetchAndSaveMissingDays(UsageService service, UsageDatabase db) async {
  final now = DateTime.now();
  
  // Check last 7 days
  for (int i = 1; i <= 7; i++) {
    final date = now.subtract(Duration(days: i));
    
    // Check if data exists for this date
    final existingData = await db.getDailyUsage(date);
    
    // If no data or empty data, try to fetch from Android API
    if (existingData == null || existingData.totalScreenTime.inSeconds == 0) {
      final apps = await service.fetchUsageDataForDate(date);
      
      if (apps.isNotEmpty) {
        final totalTime = service.calculateTotalScreenTime(apps);
        final dailyUsage = DailyUsage(
          date: date,
          totalScreenTime: totalTime,
          unlockCount: 0,
          notificationCount: 0,
          apps: apps,
        );
        await db.saveDailyUsage(dailyUsage);
      }
    }
  }
}

final totalScreenTimeProvider = Provider<Duration>((ref) {
  final usageAsync = ref.watch(appUsageProvider);
  
  return usageAsync.when(
    data: (apps) {
      final service = ref.watch(usageServiceProvider);
      return service.calculateTotalScreenTime(apps);
    },
    loading: () => Duration.zero,
    error: (_, __) => Duration.zero,
  );
});

final top5AppsProvider = Provider<List<AppUsageInfo>>((ref) {
  final usageAsync = ref.watch(appUsageProvider);
  
  return usageAsync.when(
    data: (apps) {
      final service = ref.watch(usageServiceProvider);
      return service.getTopApps(apps, 5);
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Feature settings providers
final appTimersProvider = FutureProvider<List<AppTimer>>((ref) async {
  final db = ref.watch(usageDatabaseProvider);
  return await db.getAppTimers();
});

final bedtimeSettingsProvider = FutureProvider<BedtimeSettings>((ref) async {
  final db = ref.watch(usageDatabaseProvider);
  return await db.getBedtimeSettings();
});

final focusSettingsProvider = FutureProvider<FocusSettings>((ref) async {
  final db = ref.watch(usageDatabaseProvider);
  return await db.getFocusSettings();
});

final screenTimeRemindersProvider = FutureProvider<List<ScreenTimeReminder>>((ref) async {
  final db = ref.watch(usageDatabaseProvider);
  return await db.getScreenTimeReminders();
});

// Weekly usage history provider
final weeklyUsageHistoryProvider = FutureProvider<List<DailyUsage>>((ref) async {
  final db = ref.watch(usageDatabaseProvider);
  return await db.getUsageHistory(7);
});
