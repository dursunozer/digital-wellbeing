import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/dashboard_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'utils/app_themes.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(
    // Wrap the app with ProviderScope for Riverpod
    const ProviderScope(
      child: MyApp(),
    ),
  );
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
