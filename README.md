# Digital Wellbeing

Digital Wellbeing is a Flutter-based mobile application that helps users understand and manage their phone usage habits. The app focuses on screen time awareness, app activity tracking, focus mode, bedtime settings, app timers, and screen time reminders.

The project is built with Flutter and Dart, uses Riverpod for state management, supports English and Turkish localization, and stores user preferences and usage-related settings locally.

## Features

- **Daily screen time dashboard**  
  View today’s total screen time and the most used apps in a clean dashboard.

- **App usage tracking**  
  Fetch and display app usage data from Android usage access APIs.

- **Top apps overview**  
  See the apps that consume the most screen time.

- **App timers**  
  Set daily limits for individual apps and track progress against those limits.

- **Focus mode**  
  Select distracting apps and enable a focus mode experience.

- **Bedtime mode settings**  
  Configure bedtime start/end times and active days.

- **Screen time reminders**  
  Create reminders based on screen time thresholds.

- **Dark and light theme support**  
  Switch between light and dark mode.

- **English and Turkish localization**  
  The app supports both `en` and `tr` locales.

- **Local data storage**  
  Settings and usage-related data are stored locally using SQLite and SharedPreferences.

## Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform mobile app development |
| Dart | Main programming language |
| Riverpod | State management |
| app_usage | Android app usage statistics |
| installed_apps | App metadata and installed app information |
| fl_chart | Usage charts and visualizations |
| permission_handler | Permission management |
| sqflite | Local SQLite database |
| shared_preferences | Local key-value storage |
| workmanager | Background tasks |
| flutter_local_notifications | Local notifications |
| intl / flutter_localizations | Internationalization and localization |

## Project Structure

```txt
lib/
├── l10n/          # Localization files
├── models/        # Data models
├── providers/     # Riverpod providers
├── screens/       # App screens
├── services/      # Usage, database, notification and background services
├── utils/         # Theme and helper utilities
├── widgets/       # Reusable UI components
└── main.dart      # Application entry point
```

## Getting Started

### Prerequisites

Make sure you have the following installed:

- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- Android device or emulator

### Installation

Clone the repository:

```bash
git clone https://github.com/dursunozer/digital-wellbeing.git
cd digital-wellbeing
```

Install dependencies:

```bash
flutter pub get
```

Run the project:

```bash
flutter run
```

## Android Permissions

This project needs Android usage access permission to read app usage statistics. Usage access is a special Android permission, so the user may need to enable it manually from system settings.

Typical flow:

1. Open the app.
2. Grant the requested permissions.
3. If usage access is not enabled, go to Android settings.
4. Enable usage access for the app.
5. Return to the app and refresh the dashboard.

## Build

Create a release APK:

```bash
flutter build apk --release
```

Create an Android App Bundle:

```bash
flutter build appbundle --release
```

## Future Improvements

- More detailed weekly and monthly analytics
- Better focus mode enforcement
- Custom notification schedules
- Usage history charts
- Exportable reports
- More advanced app category analysis

## License

No license file is currently provided in this repository. Add a license before distributing or reusing the project publicly.
