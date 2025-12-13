import 'dart:typed_data';
import 'package:installed_apps/installed_apps.dart';

/// Cached app information containing icon and name
class CachedAppInfo {
  final Uint8List? icon;
  final String? name;
  
  const CachedAppInfo({this.icon, this.name});
}

class IconCacheService {

  static final IconCacheService _instance = IconCacheService._internal();
  factory IconCacheService() => _instance;
  IconCacheService._internal();

  // Cache for icons
  final Map<String, Uint8List?> _iconCache = {};
  
  // Cache for app names
  final Map<String, String?> _nameCache = {};
  
  // Packages that failed to load
  final Set<String> _failedPackages = {};
  
  // Track in-progress fetches to avoid duplicate calls
  final Map<String, Future<CachedAppInfo>> _pendingFetches = {};

  /// Get both icon and name for a package in a single call
  /// This is more efficient than calling getIcon and getAppName separately
  Future<CachedAppInfo> getAppInfo(String packageName) async {
    // Return from cache if available
    if (_iconCache.containsKey(packageName) && _nameCache.containsKey(packageName)) {
      return CachedAppInfo(
        icon: _iconCache[packageName],
        name: _nameCache[packageName],
      );
    }

    // Return early for known failed packages
    if (_failedPackages.contains(packageName)) {
      return const CachedAppInfo();
    }

    // Check if there's already a fetch in progress for this package
    if (_pendingFetches.containsKey(packageName)) {
      return _pendingFetches[packageName]!;
    }

    // Start new fetch and track it
    final future = _fetchAppInfo(packageName);
    _pendingFetches[packageName] = future;
    
    try {
      final result = await future;
      return result;
    } finally {
      _pendingFetches.remove(packageName);
    }
  }

  /// Internal method to fetch app info from system
  Future<CachedAppInfo> _fetchAppInfo(String packageName) async {
    try {
      final app = await InstalledApps.getAppInfo(packageName, null);
      
      if (app != null) {
        // Cache both icon and name
        _iconCache[packageName] = (app.icon != null && app.icon!.isNotEmpty) ? app.icon : null;
        _nameCache[packageName] = app.name;
        
        return CachedAppInfo(
          icon: _iconCache[packageName],
          name: _nameCache[packageName],
        );
      } else {
        _iconCache[packageName] = null;
        _nameCache[packageName] = null;
        return const CachedAppInfo();
      }
    } catch (e) {
      _failedPackages.add(packageName);
      _iconCache[packageName] = null;
      _nameCache[packageName] = null;
      return const CachedAppInfo();
    }
  }

  /// Get cached icon (legacy method for compatibility)
  Future<Uint8List?> getIcon(String packageName) async {
    final info = await getAppInfo(packageName);
    return info.icon;
  }

  /// Get cached app name
  Future<String?> getAppName(String packageName) async {
    final info = await getAppInfo(packageName);
    return info.name;
  }

  /// Check if package info is cached
  bool isCached(String packageName) {
    return _iconCache.containsKey(packageName) && _nameCache.containsKey(packageName);
  }

  /// Check if only icon is cached (for backwards compatibility)
  bool isIconCached(String packageName) {
    return _iconCache.containsKey(packageName);
  }

  void clearCache() {
    _iconCache.clear();
    _nameCache.clear();
    _failedPackages.clear();
    _pendingFetches.clear();
  }

  int get cacheSize => _iconCache.length;
}

