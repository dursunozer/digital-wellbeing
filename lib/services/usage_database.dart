import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/app_usage_info.dart';
import '../models/daily_usage.dart';
import '../models/feature_settings.dart';

/// SQLite database service for storing usage data and feature settings
class UsageDatabase {
  static Database? _database;
  static const String _dbName = 'digital_wellbeing.db';
  static const int _dbVersion = 1;

  /// Get or create database instance
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Daily usage table
    await db.execute('''
      CREATE TABLE daily_usage (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT UNIQUE NOT NULL,
        totalScreenTimeSeconds INTEGER NOT NULL DEFAULT 0,
        unlockCount INTEGER NOT NULL DEFAULT 0,
        notificationCount INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // App usage per day table
    await db.execute('''
      CREATE TABLE app_usage (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dailyUsageId INTEGER NOT NULL,
        packageName TEXT NOT NULL,
        appName TEXT NOT NULL,
        usageSeconds INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (dailyUsageId) REFERENCES daily_usage(id) ON DELETE CASCADE
      )
    ''');

    // App timers table
    await db.execute('''
      CREATE TABLE app_timers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        packageName TEXT UNIQUE NOT NULL,
        appName TEXT NOT NULL,
        dailyLimitMinutes INTEGER NOT NULL,
        isEnabled INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Bedtime settings table (single row)
    await db.execute('''
      CREATE TABLE bedtime_settings (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        startHour INTEGER NOT NULL DEFAULT 22,
        startMinute INTEGER NOT NULL DEFAULT 0,
        endHour INTEGER NOT NULL DEFAULT 7,
        endMinute INTEGER NOT NULL DEFAULT 0,
        isEnabled INTEGER NOT NULL DEFAULT 0,
        activeDays TEXT NOT NULL DEFAULT '1,2,3,4,5,6,7',
        grayscale INTEGER NOT NULL DEFAULT 0,
        doNotDisturb INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Focus mode settings table (single row)
    await db.execute('''
      CREATE TABLE focus_settings (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        isEnabled INTEGER NOT NULL DEFAULT 0,
        blockedPackages TEXT NOT NULL DEFAULT '',
        scheduledDurationMinutes INTEGER,
        focusName TEXT
      )
    ''');

    // Screen time reminders table
    await db.execute('''
      CREATE TABLE screen_time_reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        thresholdMinutes INTEGER NOT NULL,
        isEnabled INTEGER NOT NULL DEFAULT 1,
        message TEXT
      )
    ''');

    // Insert default settings
    await db.insert('bedtime_settings', {'id': 1});
    await db.insert('focus_settings', {'id': 1});
  }

  // ==================== Daily Usage ====================

  /// Save or update daily usage for today
  Future<void> saveDailyUsage(DailyUsage usage) async {
    final db = await database;
    final dateStr = usage.date.toIso8601String().split('T')[0];

    // Check if record exists
    final existing = await db.query(
      'daily_usage',
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    int dailyUsageId;
    if (existing.isEmpty) {
      dailyUsageId = await db.insert('daily_usage', {
        'date': dateStr,
        'totalScreenTimeSeconds': usage.totalScreenTime.inSeconds,
        'unlockCount': usage.unlockCount,
        'notificationCount': usage.notificationCount,
      });
    } else {
      dailyUsageId = existing.first['id'] as int;
      await db.update(
        'daily_usage',
        {
          'totalScreenTimeSeconds': usage.totalScreenTime.inSeconds,
          'unlockCount': usage.unlockCount,
          'notificationCount': usage.notificationCount,
        },
        where: 'id = ?',
        whereArgs: [dailyUsageId],
      );
      // Delete old app usage records
      await db.delete('app_usage', where: 'dailyUsageId = ?', whereArgs: [dailyUsageId]);
    }

    // Insert app usage records
    for (final app in usage.apps) {
      await db.insert('app_usage', {
        'dailyUsageId': dailyUsageId,
        'packageName': app.packageName,
        'appName': app.appName,
        'usageSeconds': app.usageDuration.inSeconds,
      });
    }
  }

  /// Get daily usage for a specific date
  Future<DailyUsage?> getDailyUsage(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];

    final dailyUsageRows = await db.query(
      'daily_usage',
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    if (dailyUsageRows.isEmpty) return null;

    final row = dailyUsageRows.first;
    final dailyUsageId = row['id'] as int;

    // Get app usage for this day
    final appUsageRows = await db.query(
      'app_usage',
      where: 'dailyUsageId = ?',
      whereArgs: [dailyUsageId],
    );

    final apps = appUsageRows.map((appRow) {
      return AppUsageInfo(
        packageName: appRow['packageName'] as String,
        appName: appRow['appName'] as String,
        usageDuration: Duration(seconds: appRow['usageSeconds'] as int),
      );
    }).toList();

    return DailyUsage.fromJson(row, apps: apps);
  }

  /// Get usage history for last N days
  Future<List<DailyUsage>> getUsageHistory(int days) async {
    final db = await database;
    final startDate = DateTime.now().subtract(Duration(days: days));
    final startDateStr = startDate.toIso8601String().split('T')[0];

    final rows = await db.query(
      'daily_usage',
      where: 'date >= ?',
      whereArgs: [startDateStr],
      orderBy: 'date DESC',
    );

    final List<DailyUsage> history = [];
    for (final row in rows) {
      final dailyUsageId = row['id'] as int;
      final appUsageRows = await db.query(
        'app_usage',
        where: 'dailyUsageId = ?',
        whereArgs: [dailyUsageId],
      );

      final apps = appUsageRows.map((appRow) {
        return AppUsageInfo(
          packageName: appRow['packageName'] as String,
          appName: appRow['appName'] as String,
          usageDuration: Duration(seconds: appRow['usageSeconds'] as int),
        );
      }).toList();

      history.add(DailyUsage.fromJson(row, apps: apps));
    }

    return history;
  }

  // ==================== App Timers ====================

  /// Get all app timers
  Future<List<AppTimer>> getAppTimers() async {
    final db = await database;
    final rows = await db.query('app_timers');
    return rows.map((row) => AppTimer.fromJson(row)).toList();
  }

  /// Save or update an app timer
  Future<void> saveAppTimer(AppTimer timer) async {
    final db = await database;
    final existing = await db.query(
      'app_timers',
      where: 'packageName = ?',
      whereArgs: [timer.packageName],
    );

    if (existing.isEmpty) {
      await db.insert('app_timers', timer.toJson()..remove('id'));
    } else {
      await db.update(
        'app_timers',
        timer.toJson()..remove('id'),
        where: 'packageName = ?',
        whereArgs: [timer.packageName],
      );
    }
  }

  /// Delete an app timer
  Future<void> deleteAppTimer(String packageName) async {
    final db = await database;
    await db.delete('app_timers', where: 'packageName = ?', whereArgs: [packageName]);
  }

  // ==================== Bedtime Settings ====================

  /// Get bedtime settings
  Future<BedtimeSettings> getBedtimeSettings() async {
    final db = await database;
    final rows = await db.query('bedtime_settings', where: 'id = 1');
    if (rows.isEmpty) {
      return BedtimeSettings();
    }
    return BedtimeSettings.fromJson(rows.first);
  }

  /// Save bedtime settings
  Future<void> saveBedtimeSettings(BedtimeSettings settings) async {
    final db = await database;
    await db.update(
      'bedtime_settings',
      settings.toJson()..['id'] = 1,
      where: 'id = 1',
    );
  }

  // ==================== Focus Settings ====================

  /// Get focus mode settings
  Future<FocusSettings> getFocusSettings() async {
    final db = await database;
    final rows = await db.query('focus_settings', where: 'id = 1');
    if (rows.isEmpty) {
      return FocusSettings();
    }
    return FocusSettings.fromJson(rows.first);
  }

  /// Save focus mode settings
  Future<void> saveFocusSettings(FocusSettings settings) async {
    final db = await database;
    await db.update(
      'focus_settings',
      settings.toJson()..['id'] = 1,
      where: 'id = 1',
    );
  }

  // ==================== Screen Time Reminders ====================

  /// Get all screen time reminders
  Future<List<ScreenTimeReminder>> getScreenTimeReminders() async {
    final db = await database;
    final rows = await db.query('screen_time_reminders');
    return rows.map((row) => ScreenTimeReminder.fromJson(row)).toList();
  }

  /// Save or update a screen time reminder
  Future<void> saveScreenTimeReminder(ScreenTimeReminder reminder) async {
    final db = await database;
    if (reminder.id == null) {
      await db.insert('screen_time_reminders', reminder.toJson()..remove('id'));
    } else {
      await db.update(
        'screen_time_reminders',
        reminder.toJson(),
        where: 'id = ?',
        whereArgs: [reminder.id],
      );
    }
  }

  /// Delete a screen time reminder
  Future<void> deleteScreenTimeReminder(int id) async {
    final db = await database;
    await db.delete('screen_time_reminders', where: 'id = ?', whereArgs: [id]);
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
