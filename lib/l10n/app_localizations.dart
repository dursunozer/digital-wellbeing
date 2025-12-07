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
