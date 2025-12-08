
import 'package:app_usage/app_usage.dart' as app_usage;
import 'package:installed_apps/installed_apps.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/app_usage_info.dart';
import 'preferences_service.dart';
import 'icon_cache_service.dart';

/// Service class to handle app usage data fetching and permission management
class UsageService {
  final app_usage.AppUsage _appUsage = app_usage.AppUsage();
  final PreferencesService _preferencesService;
  final IconCacheService _iconCache = IconCacheService();

  UsageService(this._preferencesService);

  /// Minimum usage threshold in milliseconds (1 second for testing)
  static const int minUsageThreshold = 1 * 1000;

  /// Check if PACKAGE_USAGE_STATS permission is granted
  Future<bool> isPermissionGranted() async {
    // Note: permission_handler may not accurately check this permission
    // We'll try to fetch usage and catch any errors
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(hours: 1));
      await _appUsage.getAppUsage(startDate, endDate);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Open Android Settings for granting PACKAGE_USAGE_STATS permission
  /// This is a special permission that cannot be requested via standard runtime permissions
  Future<bool> requestPermission() async {
    try {
      // Open app settings where user can grant usage access permission
      final opened = await openAppSettings();
      return opened;
    } catch (e) {
      return false;
    }
  }

  /// Fetch app usage data for the last 24 hours
  Future<List<AppUsageInfo>> fetchUsageData() async {
    try {
      // Check if user has manually reset (get reset timestamp)
      final resetTimestamp = await _preferencesService.getResetTimestamp();
      
      // ALWAYS fetch last 24 hours - baseline subtraction handles the reset
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(hours: 24));

      // Fetch usage stats from app_usage package
      final List<app_usage.AppUsageInfo> usageInfoList = 
          await _appUsage.getAppUsage(startDate, endDate);

      // Convert to our model with app metadata
      final enrichedList = await _enrichWithAppMetadata(usageInfoList);

      // Subtract baseline if reset is active
      List<AppUsageInfo> adjustedList = enrichedList;
      if (resetTimestamp != null) {
        final baseline = await _preferencesService.getResetBaseline();
        
        adjustedList = <AppUsageInfo>[];
        for (final app in enrichedList) {
          final baselineSeconds = baseline[app.packageName] ?? 0;
          final currentSeconds = app.usageDuration.inSeconds;
          final adjustedSeconds = currentSeconds - baselineSeconds;
          
          // Only include apps with positive usage after reset
          if (adjustedSeconds > 0) {
            adjustedList.add(AppUsageInfo(
              packageName: app.packageName,
              appName: app.appName,
              appIcon: app.appIcon,
              usageDuration: Duration(seconds: adjustedSeconds),
            ));
          }
          // Apps with zero or negative adjusted usage are excluded
        }
      }

      // Filter out system apps and apps with minimal usage
      final filteredList = _filterApps(adjustedList);

      // Sort by usage duration (descending)
      filteredList.sort((a, b) => b.usageDuration.compareTo(a.usageDuration));

      return filteredList;
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch RAW usage data for the last 24 hours WITHOUT baseline subtraction
  /// This is used for reset baseline calculation
  Future<List<AppUsageInfo>> fetchRawUsageData() async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(hours: 24));

      // Fetch usage stats from app_usage package
      final List<app_usage.AppUsageInfo> usageInfoList = 
          await _appUsage.getAppUsage(startDate, endDate);

      // Convert to our model with app metadata (NO baseline subtraction)
      final enrichedList = await _enrichWithAppMetadata(usageInfoList);

      return enrichedList;
    } catch (e) {
      rethrow;
    }
  }

  /// Enrich usage data with app metadata (name, icon) - uses icon cache
  Future<List<AppUsageInfo>> _enrichWithAppMetadata(
      List<app_usage.AppUsageInfo> usageList) async {
    final enrichedList = <AppUsageInfo>[];

    for (final usage in usageList) {
      try {
        // Get cached icon
        final icon = await _iconCache.getIcon(usage.packageName);
        
        // Get app name
        String appName;
        try {
          final app = await InstalledApps.getAppInfo(usage.packageName, null);
          if (app != null) {
            appName = _getFriendlyAppName(app.name, usage.packageName);
          } else {
            appName = _getFriendlyAppName(usage.packageName, usage.packageName);
          }
        } catch (e) {
          appName = _getFriendlyAppName(usage.packageName, usage.packageName);
        }

        enrichedList.add(AppUsageInfo(
          packageName: usage.packageName,
          appName: appName,
          appIcon: icon,
          usageDuration: usage.usage,
        ));
      } catch (e) {
        // If we can't get app info, use friendly name from package
        enrichedList.add(AppUsageInfo(
          packageName: usage.packageName,
          appName: _getFriendlyAppName(usage.packageName, usage.packageName),
          appIcon: null,
          usageDuration: usage.usage,
        ));
      }
    }

    return enrichedList;
  }

  /// Get friendly app name - convert package name to readable name if needed
  String _getFriendlyAppName(String appName, String packageName) {
    // If appName doesn't look like a package name, use it as-is
    if (!appName.contains('.') || !appName.contains('com')) {
      return appName;
    }

    // It looks like a package name, so parse it intelligently
    return _extractAppNameFromPackage(packageName);
  }

  /// Extract readable app name from package name
  String _extractAppNameFromPackage(String packageName) {
    // Remove common prefixes to get the actual app identifier
    String cleaned = packageName
        .replaceFirst('com.android.', '')
        .replaceFirst('com.google.android.apps.', '')
        .replaceFirst('com.google.android.', '')
        .replaceFirst('com.', '');

    // Get the last meaningful segment
    final segments = cleaned.split('.');
    String appIdentifier = segments.last;

    // Handle special abbreviations and common names
    final specialCases = {
      'gm': 'Gmail',
      'youtube': 'YouTube',
      'whatsapp': 'WhatsApp',
      'instagram': 'Instagram',
      'facebook': 'Facebook',
      'twitter': 'Twitter',
      'spotify': 'Spotify',
      'chrome': 'Chrome',
      'photos': 'Photos',
      'maps': 'Maps',
      'messaging': 'Messages',
      'dialer': 'Phone',
      'contacts': 'Contacts',
      'settings': 'Settings',
      'googlequicksearchbox': 'Google',
      'nexuslauncher': 'Launcher',
      'deskclock': 'Clock',
      'calculator': 'Calculator',
      'camera': 'Camera',
      'gallery': 'Gallery',
      'music': 'Music',
      'video': 'Video',
      'browser': 'Browser',
    };

    final lowerIdentifier = appIdentifier.toLowerCase();
    if (specialCases.containsKey(lowerIdentifier)) {
      return specialCases[lowerIdentifier]!;
    }

    // Default: capitalize first letter
    if (appIdentifier.isNotEmpty) {
      return appIdentifier[0].toUpperCase() + appIdentifier.substring(1);
    }

    return packageName; // Fallback to package name
  }



  /// Filter out system apps, launchers, and apps with minimal usage
  List<AppUsageInfo> _filterApps(List<AppUsageInfo> apps) {
    return apps.where((app) {
      // Filter out apps with less than 1 minute usage
      if (app.usageInMilliseconds < minUsageThreshold) {
        return false;
      }

      // Filter out system packages, launchers, and our own app
      final excludedPackages = [
        // System
        'com.android.systemui',
        'com.google.android.gms',
        // Launchers
        'com.android.launcher',
        'com.android.launcher3',
        'com.google.android.apps.nexuslauncher', // Pixel
        'com.sec.android.app.launcher',          // Samsung
        'com.huawei.android.launcher',           // Huawei
        'com.miui.home',                         // Xiaomi
        'com.oppo.launcher',                     // Oppo
        'com.oneplus.launcher',                  // OnePlus
        'com.vivo.launcher',                     // Vivo
        'com.teslacoilsw.launcher',              // Nova Launcher
        'com.microsoft.launcher',                // Microsoft Launcher
        // Our own app
        'com.ozer.digitalwellbeing.digital_wellbeing',
      ];

      return !excludedPackages.any((pkg) => app.packageName.contains(pkg));
    }).toList();
  }

  /// Calculate total screen time from a list of apps
  Duration calculateTotalScreenTime(List<AppUsageInfo> apps) {
    if (apps.isEmpty) return Duration.zero;

    return apps.fold(
      Duration.zero,
      (total, app) => total + app.usageDuration,
    );
  }

  /// Get top N most used apps
  List<AppUsageInfo> getTopApps(List<AppUsageInfo> apps, int count) {
    if (apps.length <= count) return apps;
    return apps.sublist(0, count);
  }
}
