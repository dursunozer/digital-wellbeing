import 'dart:typed_data';

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

  int get usageInMilliseconds => usageDuration.inMilliseconds;

  int get usageInMinutes => usageDuration.inMinutes;

  double get usageInHours => usageDuration.inMinutes / 60;

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

  Map<String, dynamic> toJson() {
    return {
      'packageName': packageName,
      'appName': appName,
      'usageInMilliseconds': usageInMilliseconds,
    };
  }

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
