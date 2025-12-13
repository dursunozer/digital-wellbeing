import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/dashboard_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'utils/app_themes.dart';
import 'l10n/app_localizations.dart';
import 'services/background_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Start app immediately, initialize services in background
  runApp(
    // Wrap the app with ProviderScope for Riverpod
    const ProviderScope(
      child: MyApp(),
    ),
  );
  
  // Initialize services in background after UI starts
  _initializeServicesInBackground();
}

/// Initialize notification and background services asynchronously
/// This prevents blocking the main thread during app startup
void _initializeServicesInBackground() {
  Future.microtask(() async {
    try {
      // Initialize notification service
      final notificationService = NotificationService();
      await notificationService.initialize();
      
      // Request notification permission
      await notificationService.requestPermission();
      
      // Initialize background service for periodic data saving
      await BackgroundService.initialize();
      await BackgroundService.registerPeriodicTask();
    } catch (e) {
      // Silently handle errors - services will work on next app start
    }
  });
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Digital Wellbeing',
      debugShowCheckedModeBanner: false,
      
      // Localization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
      ],
      locale: locale,
      
      // Theming
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeMode,
      
      home: const DashboardScreen(),
    );
  }
}
