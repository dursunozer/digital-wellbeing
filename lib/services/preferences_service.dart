import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _lastFetchDateKey = 'last_fetch_date';
  static const String _resetTimestampKey = 'reset_timestamp';
  static const String _resetBaselineKey = 'reset_baseline';
  static const String _installationDateKey = 'installation_date'; 

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<DateTime?> getLastFetchDate() async {
    final prefs = await _instance;
    final dateString = prefs.getString(_lastFetchDateKey);
    
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }

  Future<void> setLastFetchDate(DateTime date) async {
    final prefs = await _instance;
    await prefs.setString(_lastFetchDateKey, date.toIso8601String());
  }

  Future<DateTime?> getResetTimestamp() async {
    final prefs = await _instance;
    final timestampString = prefs.getString(_resetTimestampKey);
    
    if (timestampString != null) {
      return DateTime.parse(timestampString);
    }
    return null;
  }

  Future<void> setResetTimestamp(DateTime timestamp) async {
    final prefs = await _instance;
    await prefs.setString(_resetTimestampKey, timestamp.toIso8601String());
  }

  Future<Map<String, int>> getResetBaseline() async {
    final prefs = await _instance;
    final jsonString = prefs.getString(_resetBaselineKey);
    
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded = 
            Map<String, dynamic>.from(jsonDecode(jsonString) as Map);
        final result = decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
        return result;
      } catch (e) {
      }
    }
    return {};
  }

  Future<void> setResetBaseline(Map<String, int> baseline) async {
    final prefs = await _instance;
    final jsonString = jsonEncode(baseline);
    await prefs.setString(_resetBaselineKey, jsonString);
  }

  Future<void> clearResetTimestamp() async {
    final prefs = await _instance;
    await prefs.remove(_resetTimestampKey);
    await prefs.remove(_resetBaselineKey); 
  }

  Future<bool> isNewDay() async {
    final lastDate = await getLastFetchDate();
    
    if (lastDate == null) {
      return true; 
    }

    final now = DateTime.now();
    return lastDate.day != now.day ||
           lastDate.month != now.month ||
           lastDate.year != now.year;
  }

  Future<void> clear() async {
    final prefs = await _instance;
    await prefs.clear();
    _prefs = null; 
  }

  /// Get the installation date (first time app was opened)
  Future<DateTime?> getInstallationDate() async {
    final prefs = await _instance;
    final dateString = prefs.getString(_installationDateKey);
    
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }

  /// Set installation date if not already set
  Future<void> setInstallationDateIfNeeded() async {
    final existing = await getInstallationDate();
    if (existing == null) {
      final prefs = await _instance;
      await prefs.setString(_installationDateKey, DateTime.now().toIso8601String());
    }
  }

  /// Check if a date is after installation
  Future<bool> isAfterInstallation(DateTime date) async {
    final installDate = await getInstallationDate();
    if (installDate == null) return false;
    
    // Compare dates only (not time)
    final installDay = DateTime(installDate.year, installDate.month, installDate.day);
    final checkDay = DateTime(date.year, date.month, date.day);
    
    return !checkDay.isBefore(installDay);
  }
}
