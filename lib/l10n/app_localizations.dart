import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Digital Wellbeing'**
  String get appTitle;

  /// No description provided for @totalScreenTime.
  ///
  /// In en, this message translates to:
  /// **'Total Screen Time Today'**
  String get totalScreenTime;

  /// No description provided for @last24Hours.
  ///
  /// In en, this message translates to:
  /// **'Last 24 hours'**
  String get last24Hours;

  /// No description provided for @topApps.
  ///
  /// In en, this message translates to:
  /// **'Top 5 Most Used Apps'**
  String get topApps;

  /// No description provided for @allApps.
  ///
  /// In en, this message translates to:
  /// **'All Apps ({count})'**
  String allApps(int count);

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @permissionMessage.
  ///
  /// In en, this message translates to:
  /// **'To track your app usage, we need permission to access usage statistics. This is a special Android permission that requires manual activation in Settings.'**
  String get permissionMessage;

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// No description provided for @whyPermission.
  ///
  /// In en, this message translates to:
  /// **'Why do we need this permission?'**
  String get whyPermission;

  /// No description provided for @trackUsage.
  ///
  /// In en, this message translates to:
  /// **'Track Usage'**
  String get trackUsage;

  /// No description provided for @trackUsageDesc.
  ///
  /// In en, this message translates to:
  /// **'Monitor how much time you spend on each app'**
  String get trackUsageDesc;

  /// No description provided for @gainInsights.
  ///
  /// In en, this message translates to:
  /// **'Gain Insights'**
  String get gainInsights;

  /// No description provided for @gainInsightsDesc.
  ///
  /// In en, this message translates to:
  /// **'Understand your digital habits and patterns'**
  String get gainInsightsDesc;

  /// No description provided for @reduceScreenTime.
  ///
  /// In en, this message translates to:
  /// **'Reduce Screen Time'**
  String get reduceScreenTime;

  /// No description provided for @reduceScreenTimeDesc.
  ///
  /// In en, this message translates to:
  /// **'Make informed decisions about your app usage'**
  String get reduceScreenTimeDesc;

  /// No description provided for @privacyNote.
  ///
  /// In en, this message translates to:
  /// **'Your data stays on your device and is never shared'**
  String get privacyNote;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No app usage data available'**
  String get noDataAvailable;

  /// No description provided for @startUsingApps.
  ///
  /// In en, this message translates to:
  /// **'Start using apps to see statistics'**
  String get startUsingApps;

  /// No description provided for @loadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading usage data...'**
  String get loadingData;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading usage data'**
  String get errorLoadingData;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @timeUnitHours.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get timeUnitHours;

  /// No description provided for @timeUnitMinutes.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get timeUnitMinutes;

  /// No description provided for @timeUnitSeconds.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get timeUnitSeconds;

  /// No description provided for @resetUsage.
  ///
  /// In en, this message translates to:
  /// **'Reset Usage'**
  String get resetUsage;

  /// No description provided for @resetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Usage Statistics?'**
  String get resetConfirmTitle;

  /// No description provided for @resetConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will clear all current usage data and fetch fresh statistics.'**
  String get resetConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @resetInProgress.
  ///
  /// In en, this message translates to:
  /// **'Resetting usage data...'**
  String get resetInProgress;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get today;

  /// No description provided for @unlocks.
  ///
  /// In en, this message translates to:
  /// **'Unlocks'**
  String get unlocks;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @viewAppActivityDetails.
  ///
  /// In en, this message translates to:
  /// **'View app activity details'**
  String get viewAppActivityDetails;

  /// No description provided for @waysToDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Ways to disconnect'**
  String get waysToDisconnect;

  /// No description provided for @reduceInterruptions.
  ///
  /// In en, this message translates to:
  /// **'Reduce interruptions'**
  String get reduceInterruptions;

  /// No description provided for @appTimers.
  ///
  /// In en, this message translates to:
  /// **'App timers'**
  String get appTimers;

  /// No description provided for @appTimersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No timers set'**
  String get appTimersSubtitle;

  /// No description provided for @appTimersSubtitleCount.
  ///
  /// In en, this message translates to:
  /// **'{count} timer(s) set'**
  String appTimersSubtitleCount(int count);

  /// No description provided for @bedtimeMode.
  ///
  /// In en, this message translates to:
  /// **'Bedtime mode'**
  String get bedtimeMode;

  /// No description provided for @bedtimeModeOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get bedtimeModeOff;

  /// No description provided for @bedtimeModeSchedule.
  ///
  /// In en, this message translates to:
  /// **'{start} - {end}'**
  String bedtimeModeSchedule(String start, String end);

  /// No description provided for @focus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focus;

  /// No description provided for @focusTapToSetUp.
  ///
  /// In en, this message translates to:
  /// **'Tap to set up'**
  String get focusTapToSetUp;

  /// No description provided for @focusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get focusActive;

  /// No description provided for @screenTimeReminders.
  ///
  /// In en, this message translates to:
  /// **'Screen time reminders'**
  String get screenTimeReminders;

  /// No description provided for @screenTimeRemindersOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get screenTimeRemindersOff;

  /// No description provided for @screenTimeRemindersOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get screenTimeRemindersOn;

  /// No description provided for @manageNotifications.
  ///
  /// In en, this message translates to:
  /// **'Manage notifications'**
  String get manageNotifications;

  /// No description provided for @headsUp.
  ///
  /// In en, this message translates to:
  /// **'Heads Up'**
  String get headsUp;

  /// No description provided for @headsUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to set up'**
  String get headsUpSubtitle;

  /// No description provided for @appActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'App activity'**
  String get appActivityTitle;

  /// No description provided for @dailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Daily average'**
  String get dailyAverage;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @usageByApp.
  ///
  /// In en, this message translates to:
  /// **'Usage by app'**
  String get usageByApp;

  /// No description provided for @setTimer.
  ///
  /// In en, this message translates to:
  /// **'Set timer'**
  String get setTimer;

  /// No description provided for @dailyLimit.
  ///
  /// In en, this message translates to:
  /// **'Daily limit'**
  String get dailyLimit;

  /// No description provided for @noLimit.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get noLimit;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @timerSet.
  ///
  /// In en, this message translates to:
  /// **'Timer set'**
  String get timerSet;

  /// No description provided for @timerRemoved.
  ///
  /// In en, this message translates to:
  /// **'Timer removed'**
  String get timerRemoved;

  /// No description provided for @bedtimeSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Bedtime mode'**
  String get bedtimeSettingsTitle;

  /// No description provided for @bedtimeStart.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get bedtimeStart;

  /// No description provided for @bedtimeEnd.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get bedtimeEnd;

  /// No description provided for @bedtimeActiveDays.
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get bedtimeActiveDays;

  /// No description provided for @bedtimeOptions.
  ///
  /// In en, this message translates to:
  /// **'Bedtime options'**
  String get bedtimeOptions;

  /// No description provided for @grayscale.
  ///
  /// In en, this message translates to:
  /// **'Grayscale'**
  String get grayscale;

  /// No description provided for @doNotDisturb.
  ///
  /// In en, this message translates to:
  /// **'Do Not Disturb'**
  String get doNotDisturb;

  /// No description provided for @focusModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus mode'**
  String get focusModeTitle;

  /// No description provided for @selectAppsToBlock.
  ///
  /// In en, this message translates to:
  /// **'Select apps to pause'**
  String get selectAppsToBlock;

  /// No description provided for @takeABreak.
  ///
  /// In en, this message translates to:
  /// **'Take a break'**
  String get takeABreak;

  /// No description provided for @startFocus.
  ///
  /// In en, this message translates to:
  /// **'Start focus'**
  String get startFocus;

  /// No description provided for @endFocus.
  ///
  /// In en, this message translates to:
  /// **'End focus'**
  String get endFocus;

  /// No description provided for @reminderThreshold.
  ///
  /// In en, this message translates to:
  /// **'Remind me after'**
  String get reminderThreshold;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get addReminder;

  /// No description provided for @editReminder.
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get editReminder;

  /// No description provided for @deleteReminder.
  ///
  /// In en, this message translates to:
  /// **'Delete reminder'**
  String get deleteReminder;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @limit.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get limit;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get remaining;

  /// No description provided for @limitExceeded.
  ///
  /// In en, this message translates to:
  /// **'Limit exceeded'**
  String get limitExceeded;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
