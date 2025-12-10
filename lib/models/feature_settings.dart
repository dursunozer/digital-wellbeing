import 'package:flutter/material.dart';

/// App Timer settings for limiting daily app usage
class AppTimer {
  final int? id;
  final String packageName;
  final String appName;
  final Duration dailyLimit;
  final bool isEnabled;

  AppTimer({
    this.id,
    required this.packageName,
    required this.appName,
    required this.dailyLimit,
    this.isEnabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'packageName': packageName,
      'appName': appName,
      'dailyLimitMinutes': dailyLimit.inMinutes,
      'isEnabled': isEnabled ? 1 : 0,
    };
  }

  factory AppTimer.fromJson(Map<String, dynamic> json) {
    return AppTimer(
      id: json['id'] as int?,
      packageName: json['packageName'] as String,
      appName: json['appName'] as String,
      dailyLimit: Duration(minutes: json['dailyLimitMinutes'] as int),
      isEnabled: (json['isEnabled'] as int) == 1,
    );
  }

  AppTimer copyWith({
    int? id,
    String? packageName,
    String? appName,
    Duration? dailyLimit,
    bool? isEnabled,
  }) {
    return AppTimer(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

/// Bedtime mode settings
class BedtimeSettings {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool isEnabled;
  final List<int> activeDays; // 1=Monday, 7=Sunday
  final bool grayscale;
  final bool doNotDisturb;

  BedtimeSettings({
    this.startTime = const TimeOfDay(hour: 22, minute: 0),
    this.endTime = const TimeOfDay(hour: 7, minute: 0),
    this.isEnabled = false,
    this.activeDays = const [1, 2, 3, 4, 5, 6, 7],
    this.grayscale = false,
    this.doNotDisturb = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'startHour': startTime.hour,
      'startMinute': startTime.minute,
      'endHour': endTime.hour,
      'endMinute': endTime.minute,
      'isEnabled': isEnabled ? 1 : 0,
      'activeDays': activeDays.join(','),
      'grayscale': grayscale ? 1 : 0,
      'doNotDisturb': doNotDisturb ? 1 : 0,
    };
  }

  factory BedtimeSettings.fromJson(Map<String, dynamic> json) {
    return BedtimeSettings(
      startTime: TimeOfDay(
        hour: json['startHour'] as int? ?? 22,
        minute: json['startMinute'] as int? ?? 0,
      ),
      endTime: TimeOfDay(
        hour: json['endHour'] as int? ?? 7,
        minute: json['endMinute'] as int? ?? 0,
      ),
      isEnabled: (json['isEnabled'] as int?) == 1,
      activeDays: (json['activeDays'] as String?)
              ?.split(',')
              .map((e) => int.parse(e))
              .toList() ??
          [1, 2, 3, 4, 5, 6, 7],
      grayscale: (json['grayscale'] as int?) == 1,
      doNotDisturb: (json['doNotDisturb'] as int?) == 1,
    );
  }

  BedtimeSettings copyWith({
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    bool? isEnabled,
    List<int>? activeDays,
    bool? grayscale,
    bool? doNotDisturb,
  }) {
    return BedtimeSettings(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isEnabled: isEnabled ?? this.isEnabled,
      activeDays: activeDays ?? this.activeDays,
      grayscale: grayscale ?? this.grayscale,
      doNotDisturb: doNotDisturb ?? this.doNotDisturb,
    );
  }

  String get startTimeString =>
      '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';

  String get endTimeString =>
      '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
}

/// Focus mode settings
class FocusSettings {
  final bool isEnabled;
  final List<String> blockedPackages;
  final Duration? scheduledDuration;
  final String? focusName;

  FocusSettings({
    this.isEnabled = false,
    this.blockedPackages = const [],
    this.scheduledDuration,
    this.focusName,
  });

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled ? 1 : 0,
      'blockedPackages': blockedPackages.join(','),
      'scheduledDurationMinutes': scheduledDuration?.inMinutes,
      'focusName': focusName,
    };
  }

  factory FocusSettings.fromJson(Map<String, dynamic> json) {
    final durationMinutes = json['scheduledDurationMinutes'] as int?;
    return FocusSettings(
      isEnabled: (json['isEnabled'] as int?) == 1,
      blockedPackages: (json['blockedPackages'] as String?)
              ?.split(',')
              .where((e) => e.isNotEmpty)
              .toList() ??
          [],
      scheduledDuration:
          durationMinutes != null ? Duration(minutes: durationMinutes) : null,
      focusName: json['focusName'] as String?,
    );
  }

  FocusSettings copyWith({
    bool? isEnabled,
    List<String>? blockedPackages,
    Duration? scheduledDuration,
    String? focusName,
  }) {
    return FocusSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      blockedPackages: blockedPackages ?? this.blockedPackages,
      scheduledDuration: scheduledDuration ?? this.scheduledDuration,
      focusName: focusName ?? this.focusName,
    );
  }
}

/// Screen time reminder settings
class ScreenTimeReminder {
  final int? id;
  final Duration threshold;
  final bool isEnabled;
  final String? message;

  ScreenTimeReminder({
    this.id,
    required this.threshold,
    this.isEnabled = true,
    this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'thresholdMinutes': threshold.inMinutes,
      'isEnabled': isEnabled ? 1 : 0,
      'message': message,
    };
  }

  factory ScreenTimeReminder.fromJson(Map<String, dynamic> json) {
    return ScreenTimeReminder(
      id: json['id'] as int?,
      threshold: Duration(minutes: json['thresholdMinutes'] as int),
      isEnabled: (json['isEnabled'] as int?) == 1,
      message: json['message'] as String?,
    );
  }

  ScreenTimeReminder copyWith({
    int? id,
    Duration? threshold,
    bool? isEnabled,
    String? message,
  }) {
    return ScreenTimeReminder(
      id: id ?? this.id,
      threshold: threshold ?? this.threshold,
      isEnabled: isEnabled ?? this.isEnabled,
      message: message ?? this.message,
    );
  }
}
