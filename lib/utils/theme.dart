import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0D1B2A);
  static const Color secondary = Color(0xFF1B263B);
  static const Color accent = Color(0xFF415A77);
  static const Color light = Color(0xFF778DA9);
  static const Color text = Color(0xFFE0E1DD);
  static const Color success = Color(0xFF22c55e);
  static const Color warning = Color(0xFFfacc15);
  static const Color danger = Color(0xFFef4444);
}

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.primary,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      secondary: AppColors.light,
      surface: AppColors.secondary,
      error: AppColors.danger,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.text),
      titleTextStyle: TextStyle(
        color: AppColors.text,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: AppColors.text),
      bodyMedium: TextStyle(color: AppColors.text),
      bodySmall: TextStyle(color: AppColors.light),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.primary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.accent),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.accent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.light, width: 2),
      ),
      hintStyle: const TextStyle(color: AppColors.light),
    ),

    // Use CardThemeData to match the SDK's expected type (maps the same visual props).
    cardTheme: CardThemeData(
      color: AppColors.secondary,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
