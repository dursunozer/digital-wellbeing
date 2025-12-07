import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_usage_info.dart';
import '../services/usage_service.dart';
import '../services/preferences_service.dart';

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService();
});

final usageServiceProvider = Provider<UsageService>((ref) {
  final prefsService = ref.watch(preferencesServiceProvider);
  return UsageService(prefsService);
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
      print('🌅 Reset timestamp is from a different day, clearing...');
      await prefsService.clearResetTimestamp();
    }
  }
  
  final isNewDay = await prefsService.isNewDay();
  
  if (isNewDay) {
    print('🌅 New day detected! Clearing reset data and fetching fresh...');
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
