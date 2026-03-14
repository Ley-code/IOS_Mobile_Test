import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark }

class AppTheme {
  // Theme mode storage key
  static const String _themeModeKey = 'app_theme_mode';

  // Color definitions for Dark Mode (current default)
  static const Color darkPrimary = Color.fromRGBO(15, 23, 42, 1); // Slate-900
  static const Color darkSecondary = Color(0xFF2F6BFF); // Blue accent
  static const Color darkCard = Color.fromRGBO(30, 41, 59, 1); // Slate-800
  static const Color darkText = Colors.white;
  static const Color darkTextSecondary = Color.fromRGBO(148, 163, 184, 1); // Slate-400
  static const Color darkSurface = Color.fromRGBO(51, 65, 85, 1); // Slate-700

  // Color definitions for Light Mode
  static const Color lightPrimary = Color(0xFFFFFFFF); // White
  static const Color lightSecondary = Color(0xFF2F6BFF); // Blue accent (same)
  static const Color lightCard = Color(0xFFF8FAFC); // Slate-50
  static const Color lightText = Color.fromRGBO(15, 23, 42, 1); // Slate-900
  static const Color lightTextSecondary = Color.fromRGBO(100, 116, 139, 1); // Slate-500
  static const Color lightSurface = Color(0xFFF1F5F9); // Slate-100

  // Get theme data based on mode
  static ThemeData getThemeData(AppThemeMode mode) {
    if (mode == AppThemeMode.dark) {
      return ThemeData(
        primaryColor: darkPrimary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: darkSecondary,
          primary: darkPrimary,
          secondary: darkSecondary,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: darkPrimary,
        cardColor: darkCard,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          iconTheme: IconThemeData(color: darkText),
          titleTextStyle: TextStyle(
            color: darkText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: darkText),
          bodyMedium: TextStyle(color: darkText),
          bodySmall: TextStyle(color: darkTextSecondary),
          titleLarge: TextStyle(color: darkText),
          titleMedium: TextStyle(color: darkText),
          titleSmall: TextStyle(color: darkText),
        ),
        useMaterial3: false,
      );
    } else {
      return ThemeData(
        primaryColor: lightPrimary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: lightSecondary,
          primary: lightPrimary,
          secondary: lightSecondary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: lightPrimary,
        cardColor: lightCard,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          iconTheme: IconThemeData(color: lightText),
          titleTextStyle: TextStyle(
            color: lightText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: lightText),
          bodyMedium: TextStyle(color: lightText),
          bodySmall: TextStyle(color: lightTextSecondary),
          titleLarge: TextStyle(color: lightText),
          titleMedium: TextStyle(color: lightText),
          titleSmall: TextStyle(color: lightText),
        ),
        useMaterial3: false,
      );
    }
  }

  // Get colors based on theme mode
  static AppColors getColors(AppThemeMode mode) {
    if (mode == AppThemeMode.dark) {
      return AppColors(
        primary: darkPrimary,
        secondary: darkSecondary,
        card: darkCard,
        text: darkText,
        textSecondary: darkTextSecondary,
        surface: darkSurface,
      );
    } else {
      return AppColors(
        primary: lightPrimary,
        secondary: lightSecondary,
        card: lightCard,
        text: lightText,
        textSecondary: lightTextSecondary,
        surface: lightSurface,
      );
    }
  }

  // Save theme mode to storage
  static Future<void> saveThemeMode(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  // Load theme mode from storage
  static Future<AppThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_themeModeKey);
    if (modeString == null) {
      return AppThemeMode.dark; // Default to dark mode
    }
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == modeString,
      orElse: () => AppThemeMode.dark,
    );
  }
}

class AppColors {
  final Color primary;
  final Color secondary;
  final Color card;
  final Color text;
  final Color textSecondary;
  final Color surface;

  AppColors({
    required this.primary,
    required this.secondary,
    required this.card,
    required this.text,
    required this.textSecondary,
    required this.surface,
  });
}

