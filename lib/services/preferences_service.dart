import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app preferences
class PreferencesService {
  static const String _lastFetchDateKey = 'last_fetch_date';
  static const String _resetTimestampKey = 'reset_timestamp';

  /// Get the last date when usage data was fetched
  Future<DateTime?> getLastFetchDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_lastFetchDateKey);
    
    if (dateString != null) {
      return DateTime.parse(dateString);
    }
    return null;
  }

  /// Set the last fetch date
  Future<void> setLastFetchDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastFetchDateKey, date.toIso8601String());
  }

  /// Get the timestamp when user last reset usage data
  Future<DateTime?> getResetTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final timestampString = prefs.getString(_resetTimestampKey);
    
    if (timestampString != null) {
      return DateTime.parse(timestampString);
    }
    return null;
  }

  /// Set the reset timestamp (when user manually resets)
  Future<void> setResetTimestamp(DateTime timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_resetTimestampKey, timestamp.toIso8601String());
  }

  /// Clear reset timestamp (called at midnight)
  Future<void> clearResetTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_resetTimestampKey);
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
