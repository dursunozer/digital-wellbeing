import 'package:flutter/material.dart';

class AppThemes {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2196F3), 
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.grey.shade50,
    appBarTheme: AppBarTheme(
      centerTitle: false,
      foregroundColor: Colors.white,
      elevation: 0,
      backgroundColor: const Color(0xFF2196F3),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF9800),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF0A0A0A),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      foregroundColor: Colors.white,
      elevation: 0,
      backgroundColor: Color(0xFF212121),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );

  static const List<Color> lightGradient = [
    Color(0xFF2196F3), 
    Color(0xFF00BCD4), 
  ];

  static const List<Color> darkGradient = [
    Color(0xFF212121), 
    Color(0xFF121212), 
  ];

  static const List<Color> darkAccentGradient = [
    Color(0xFFFF9800), // Orange
    Color(0xFFFFC107), // Amber
  ];
}
