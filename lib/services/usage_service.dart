import 'dart:typed_data';
import 'package:app_usage/app_usage.dart' as app_usage;
import 'package:device_apps/device_apps.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/app_usage_info.dart';
import 'preferences_service.dart';

/// Service class to handle app usage data fetching and permission management
class UsageService {
  final app_usage.AppUsage _appUsage = app_usage.AppUsage();
  final PreferencesService _preferencesService;

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
      print('Error opening settings: $e');
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

      print('📊 Fetching usage data from $startDate to $endDate');

      // Fetch usage stats from app_usage package
      final List<app_usage.AppUsageInfo> usageInfoList = 
          await _appUsage.getAppUsage(startDate, endDate);

      print('✅ Fetched ${usageInfoList.length} raw usage entries');

      // Convert to our model with app metadata
      final enrichedList = await _enrichWithAppMetadata(usageInfoList);

      print('✅ Enriched ${enrichedList.length} entries with app metadata');

      // Subtract baseline if reset is active
      List<AppUsageInfo> adjustedList = enrichedList;
      if (resetTimestamp != null) {
        final baseline = await _preferencesService.getResetBaseline();
        print('🔄 Reset active. Baseline has ${baseline.length} entries');
        
        adjustedList = <AppUsageInfo>[];
        for (final app in enrichedList) {
          final baselineSeconds = baseline[app.packageName] ?? 0;
          final currentSeconds = app.usageDuration.inSeconds;
          final adjustedSeconds = currentSeconds - baselineSeconds;
          
          print('   ${app.appName}: current=$currentSeconds, baseline=$baselineSeconds, adjusted=$adjustedSeconds');
          
          // Only include apps with positive usage after reset
          if (adjustedSeconds > 0) {
            adjustedList.add(AppUsageInfo(
              packageName: app.packageName,
              appName: app.appName,
              appIcon: app.appIcon,
              usageDuration: Duration(seconds: adjustedSeconds),
            ));
          }
          // Apps with zero or negative adjusted usage are excluded (they were only used before reset)
        }
      }

      // Filter out system apps and apps with minimal usage
      final filteredList = _filterApps(adjustedList);

      print('✅ After filtering: ${filteredList.length} apps remaining');

      // Sort by usage duration (descending)
      filteredList.sort((a, b) => b.usageDuration.compareTo(a.usageDuration));

      if (filteredList.isNotEmpty) {
        print('📱 Top 3 apps:');
        for (int i = 0; i < filteredList.length.clamp(0, 3); i++) {
          final app = filteredList[i];
          print('   ${i + 1}. ${app.appName}: ${app.usageDuration.inSeconds}s');
        }
      } else {
        print('⚠️ No apps found after filtering!');
      }

      return filteredList;
    } catch (e, stackTrace) {
      print('❌ Error fetching usage data: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Fetch RAW usage data for the last 24 hours WITHOUT baseline subtraction
  /// This is used for reset baseline calculation
  Future<List<AppUsageInfo>> fetchRawUsageData() async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(hours: 24));
      
      print('📊 Fetching RAW usage data from $startDate to $endDate');

      // Fetch usage stats from app_usage package
      final List<app_usage.AppUsageInfo> usageInfoList = 
          await _appUsage.getAppUsage(startDate, endDate);

      print('✅ Fetched ${usageInfoList.length} raw usage entries');

      // Convert to our model with app metadata (NO baseline subtraction)
      final enrichedList = await _enrichWithAppMetadata(usageInfoList);

      return enrichedList;
    } catch (e, stackTrace) {
      print('❌ Error fetching raw usage data: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Enrich usage data with app metadata (name, icon)
  Future<List<AppUsageInfo>> _enrichWithAppMetadata(
      List<app_usage.AppUsageInfo> usageList) async {
    final enrichedList = <AppUsageInfo>[];

    for (final usage in usageList) {
      try {
        // Get app info from device_apps
        final app = await DeviceApps.getApp(usage.packageName, true);

        if (app != null) {
          // Use friendly name if package name was returned
          final friendlyName = _getFriendlyAppName(app.appName, usage.packageName);
          
          // Validate and extract icon
          Uint8List? validIcon;
          try {
            final appWithIcon = app as ApplicationWithIcon?;
            if (appWithIcon != null && appWithIcon.icon.isNotEmpty) {
              // Verify icon data is valid (not corrupted)
              validIcon = appWithIcon.icon;
            }
          } catch (iconError) {
            print('⚠️ Failed to load icon for ${usage.packageName}: $iconError');
            // validIcon stays null, will use fallback
          }
          
          enrichedList.add(AppUsageInfo(
            packageName: usage.packageName,
            appName: friendlyName,
            appIcon: validIcon, // May be null if icon invalid
            usageDuration: usage.usage,
          ));
        } else {
          // App not found, use friendly name from package
          enrichedList.add(AppUsageInfo(
            packageName: usage.packageName,
            appName: _getFriendlyAppName(usage.packageName, usage.packageName),
            appIcon: null,
            usageDuration: usage.usage,
          ));
        }
      } catch (e) {
        // If we can't get app info, use friendly name from package
        enrichedList.add(AppUsageInfo(
          packageName: usage.packageName,
          appName: _getFriendlyAppName(usage.packageName, usage.packageName),
          appIcon: null,
          usageDuration : usage.usage,
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



  /// Filter out system apps and apps with minimal usage
  List<AppUsageInfo> _filterApps(List<AppUsageInfo> apps) {
    return apps.where((app) {
      // Filter out apps with less than 1 minute usage
      if (app.usageInMilliseconds < minUsageThreshold) {
        return false;
      }

      // Filter out system packages and our own app
      final excludedPackages = [
        'com.android.systemui',
        'com.android.launcher',
        'com.google.android.gms',
        'com.ozer.digitalwellbeing.digital_wellbeing', // Our own app
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
