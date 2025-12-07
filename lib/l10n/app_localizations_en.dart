// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Digital Wellbeing';

  @override
  String get totalScreenTime => 'Total Screen Time Today';

  @override
  String get last24Hours => 'Last 24 hours';

  @override
  String get topApps => 'Top 5 Most Used Apps';

  @override
  String allApps(int count) {
    return 'All Apps ($count)';
  }

  @override
  String get permissionRequired => 'Permission Required';

  @override
  String get permissionMessage =>
      'To track your app usage, we need permission to access usage statistics. This is a special Android permission that requires manual activation in Settings.';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get whyPermission => 'Why do we need this permission?';

  @override
  String get trackUsage => 'Track Usage';

  @override
  String get trackUsageDesc => 'Monitor how much time you spend on each app';

  @override
  String get gainInsights => 'Gain Insights';

  @override
  String get gainInsightsDesc => 'Understand your digital habits and patterns';

  @override
  String get reduceScreenTime => 'Reduce Screen Time';

  @override
  String get reduceScreenTimeDesc =>
      'Make informed decisions about your app usage';

  @override
  String get privacyNote =>
      'Your data stays on your device and is never shared';

  @override
  String get noDataAvailable => 'No app usage data available';

  @override
  String get startUsingApps => 'Start using apps to see statistics';

  @override
  String get loadingData => 'Loading usage data...';

  @override
  String get errorLoadingData => 'Error loading usage data';

  @override
  String get retry => 'Retry';

  @override
  String get timeUnitHours => 'h';

  @override
  String get timeUnitMinutes => 'm';

  @override
  String get timeUnitSeconds => 's';

  @override
  String get resetUsage => 'Reset Usage';

  @override
  String get resetConfirmTitle => 'Reset Usage Statistics?';

  @override
  String get resetConfirmMessage =>
      'This will clear all current usage data and fetch fresh statistics.';

  @override
  String get cancel => 'Cancel';

  @override
  String get reset => 'Reset';

  @override
  String get resetInProgress => 'Resetting usage data...';
}
