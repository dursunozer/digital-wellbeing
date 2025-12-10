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

  @override
  String get today => 'TODAY';

  @override
  String get unlocks => 'Unlocks';

  @override
  String get notifications => 'Notifications';

  @override
  String get viewAppActivityDetails => 'View app activity details';

  @override
  String get waysToDisconnect => 'Ways to disconnect';

  @override
  String get reduceInterruptions => 'Reduce interruptions';

  @override
  String get appTimers => 'App timers';

  @override
  String get appTimersSubtitle => 'No timers set';

  @override
  String appTimersSubtitleCount(int count) {
    return '$count timer(s) set';
  }

  @override
  String get bedtimeMode => 'Bedtime mode';

  @override
  String get bedtimeModeOff => 'Off';

  @override
  String bedtimeModeSchedule(String start, String end) {
    return '$start - $end';
  }

  @override
  String get focus => 'Focus';

  @override
  String get focusTapToSetUp => 'Tap to set up';

  @override
  String get focusActive => 'Active';

  @override
  String get screenTimeReminders => 'Screen time reminders';

  @override
  String get screenTimeRemindersOff => 'Off';

  @override
  String get screenTimeRemindersOn => 'On';

  @override
  String get manageNotifications => 'Manage notifications';

  @override
  String get headsUp => 'Heads Up';

  @override
  String get headsUpSubtitle => 'Tap to set up';

  @override
  String get appActivityTitle => 'App activity';

  @override
  String get dailyAverage => 'Daily average';

  @override
  String get thisWeek => 'This week';

  @override
  String get usageByApp => 'Usage by app';

  @override
  String get setTimer => 'Set timer';

  @override
  String get dailyLimit => 'Daily limit';

  @override
  String get noLimit => 'No limit';

  @override
  String get minutes => 'minutes';

  @override
  String get hours => 'hours';

  @override
  String get timerSet => 'Timer set';

  @override
  String get timerRemoved => 'Timer removed';

  @override
  String get bedtimeSettingsTitle => 'Bedtime mode';

  @override
  String get bedtimeStart => 'Start time';

  @override
  String get bedtimeEnd => 'End time';

  @override
  String get bedtimeActiveDays => 'Active days';

  @override
  String get bedtimeOptions => 'Bedtime options';

  @override
  String get grayscale => 'Grayscale';

  @override
  String get doNotDisturb => 'Do Not Disturb';

  @override
  String get focusModeTitle => 'Focus mode';

  @override
  String get selectAppsToBlock => 'Select apps to pause';

  @override
  String get takeABreak => 'Take a break';

  @override
  String get startFocus => 'Start focus';

  @override
  String get endFocus => 'End focus';

  @override
  String get reminderThreshold => 'Remind me after';

  @override
  String get addReminder => 'Add reminder';

  @override
  String get editReminder => 'Edit reminder';

  @override
  String get deleteReminder => 'Delete reminder';

  @override
  String get monday => 'Mon';

  @override
  String get tuesday => 'Tue';

  @override
  String get wednesday => 'Wed';

  @override
  String get thursday => 'Thu';

  @override
  String get friday => 'Fri';

  @override
  String get saturday => 'Sat';

  @override
  String get sunday => 'Sun';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get enable => 'Enable';

  @override
  String get disable => 'Disable';

  @override
  String get on => 'On';

  @override
  String get off => 'Off';
}
