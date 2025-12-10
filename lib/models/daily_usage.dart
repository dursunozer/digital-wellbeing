import 'app_usage_info.dart';

/// Model for storing daily usage data
class DailyUsage {
  final int? id;
  final DateTime date;
  final Duration totalScreenTime;
  final int unlockCount;
  final int notificationCount;
  final List<AppUsageInfo> apps;

  DailyUsage({
    this.id,
    required this.date,
    required this.totalScreenTime,
    this.unlockCount = 0,
    this.notificationCount = 0,
    this.apps = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0], // Store only date part
      'totalScreenTimeSeconds': totalScreenTime.inSeconds,
      'unlockCount': unlockCount,
      'notificationCount': notificationCount,
    };
  }

  factory DailyUsage.fromJson(Map<String, dynamic> json, {List<AppUsageInfo>? apps}) {
    return DailyUsage(
      id: json['id'] as int?,
      date: DateTime.parse(json['date'] as String),
      totalScreenTime: Duration(seconds: json['totalScreenTimeSeconds'] as int),
      unlockCount: json['unlockCount'] as int? ?? 0,
      notificationCount: json['notificationCount'] as int? ?? 0,
      apps: apps ?? [],
    );
  }

  DailyUsage copyWith({
    int? id,
    DateTime? date,
    Duration? totalScreenTime,
    int? unlockCount,
    int? notificationCount,
    List<AppUsageInfo>? apps,
  }) {
    return DailyUsage(
      id: id ?? this.id,
      date: date ?? this.date,
      totalScreenTime: totalScreenTime ?? this.totalScreenTime,
      unlockCount: unlockCount ?? this.unlockCount,
      notificationCount: notificationCount ?? this.notificationCount,
      apps: apps ?? this.apps,
    );
  }
}
