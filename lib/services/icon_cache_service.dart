import 'dart:typed_data';
import 'package:installed_apps/installed_apps.dart';

/// Service for caching app icons in memory to avoid repeated disk reads
class IconCacheService {
  // Singleton instance
  static final IconCacheService _instance = IconCacheService._internal();
  factory IconCacheService() => _instance;
  IconCacheService._internal();

  // In-memory cache: packageName -> icon bytes
  final Map<String, Uint8List?> _iconCache = {};
  
  // Track packages that failed to load (to avoid retrying)
  final Set<String> _failedPackages = {};

  /// Get icon for a package, using cache if available
  Future<Uint8List?> getIcon(String packageName) async {
    // Return cached icon if exists
    if (_iconCache.containsKey(packageName)) {
      return _iconCache[packageName];
    }

    // Skip if previously failed
    if (_failedPackages.contains(packageName)) {
      return null;
    }

    try {
      final app = await InstalledApps.getAppInfo(packageName, null);
      
      if (app != null && app.icon != null && app.icon!.isNotEmpty) {
        _iconCache[packageName] = app.icon;
        return app.icon;
      } else {
        _iconCache[packageName] = null;
        return null;
      }
    } catch (e) {
      _failedPackages.add(packageName);
      _iconCache[packageName] = null;
      return null;
    }
  }

  /// Get app name for a package
  Future<String?> getAppName(String packageName) async {
    try {
      final app = await InstalledApps.getAppInfo(packageName, null);
      return app?.name;
    } catch (e) {
      return null;
    }
  }

  /// Check if icon is already cached
  bool isCached(String packageName) {
    return _iconCache.containsKey(packageName);
  }

  /// Clear the cache (useful for memory management)
  void clearCache() {
    _iconCache.clear();
    _failedPackages.clear();
  }

  /// Get cache size for debugging
  int get cacheSize => _iconCache.length;
}
