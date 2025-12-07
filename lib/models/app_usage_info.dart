import 'dart:typed_data';

/// Model class representing app usage information
class AppUsageInfo {
  final String packageName;
  final String appName;
  final Uint8List? appIcon;
  final Duration usageDuration;

  AppUsageInfo({
    required this.packageName,
    required this.appName,
    this.appIcon,
    required this.usageDuration,
  });

  /// Get usage duration in milliseconds
  int get usageInMilliseconds => usageDuration.inMilliseconds;

  /// Get usage duration in minutes
  int get usageInMinutes => usageDuration.inMinutes;

  /// Get usage duration in hours
  double get usageInHours => usageDuration.inMinutes / 60;

  /// Create a copy with modified fields
  AppUsageInfo copyWith({
    String? packageName,
    String? appName,
    Uint8List? appIcon,
    Duration? usageDuration,
  }) {
    return AppUsageInfo(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      appIcon: appIcon ?? this.appIcon,
      usageDuration: usageDuration ?? this.usageDuration,
    );
  }

  /// Convert to JSON (without icon for simplicity)
  Map<String, dynamic> toJson() {
    return {
      'packageName': packageName,
      'appName': appName,
      'usageInMilliseconds': usageInMilliseconds,
    };
  }

  /// Create from JSON
  factory AppUsageInfo.fromJson(Map<String, dynamic> json) {
    return AppUsageInfo(
      packageName: json['packageName'] as String,
      appName: json['appName'] as String,
      usageDuration: Duration(milliseconds: json['usageInMilliseconds'] as int),
    );
  }

  @override
  String toString() {
    return 'AppUsageInfo(packageName: $packageName, appName: $appName, duration: ${usageDuration.inMinutes}m)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUsageInfo && other.packageName == packageName;
  }

  @override
  int get hashCode => packageName.hashCode;
}
