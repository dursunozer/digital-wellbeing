import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_usage_info.dart';
import '../models/feature_settings.dart';
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
  
 
  return await service.fetchUsageData();
});

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
