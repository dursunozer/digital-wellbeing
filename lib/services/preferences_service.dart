import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app preferences
class PreferencesService {
  static const String _lastFetchDateKey = 'last_fetch_date';
  static const String _resetTimestampKey = 'reset_timestamp';
  static const String _resetBaselineKey = 'reset_baseline'; // Map of packageName -> usage in seconds

  // Cached SharedPreferences instance
  SharedPreferences? _prefs;

  /// Get or create SharedPreferences instance (cached)
  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Get the last date when usage data was fetched
  Future<DateTime?> getLastFetchDate() async {
    final prefs = await _instance;
    final dateString = prefs.getString(_lastFetchDateKey);
    
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }

  /// Set the last fetch date
  Future<void> setLastFetchDate(DateTime date) async {
    final prefs = await _instance;
    await prefs.setString(_lastFetchDateKey, date.toIso8601String());
  }

  /// Get the timestamp when user last reset usage data
  Future<DateTime?> getResetTimestamp() async {
    final prefs = await _instance;
    final timestampString = prefs.getString(_resetTimestampKey);
    
    if (timestampString != null) {
      return DateTime.parse(timestampString);
    }
    return null;
  }

  /// Set the reset timestamp (when user manually resets)
  Future<void> setResetTimestamp(DateTime timestamp) async {
    final prefs = await _instance;
    await prefs.setString(_resetTimestampKey, timestamp.toIso8601String());
  }

  /// Get the baseline usage (app usage at reset time)
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
        // Silently handle parse errors
      }
    }
    return {};
  }

  /// Set the baseline usage (app usage at reset time)
  Future<void> setResetBaseline(Map<String, int> baseline) async {
    final prefs = await _instance;
    final jsonString = jsonEncode(baseline);
    await prefs.setString(_resetBaselineKey, jsonString);
  }

  /// Clear reset timestamp (called at midnight)
  Future<void> clearResetTimestamp() async {
    final prefs = await _instance;
    await prefs.remove(_resetTimestampKey);
    await prefs.remove(_resetBaselineKey); // Also clear baseline
  }

  /// Check if we're on a new day (midnight has passed)
  Future<bool> isNewDay() async {
    final lastDate = await getLastFetchDate();
    
    if (lastDate == null) {
      return true; // First time, consider it new day
    }

    final now = DateTime.now();
    
    // Check if day, month, or year has changed
    return lastDate.day != now.day ||
           lastDate.month != now.month ||
           lastDate.year != now.year;
  }

  /// Clear all preferences (for testing)
  Future<void> clear() async {
    final prefs = await _instance;
    await prefs.clear();
    _prefs = null; // Reset cache after clear
  }
}
