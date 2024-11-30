import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ColorScheme colorScheme = const ColorScheme(
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    error: AppColors.error,
    onError: AppColors.onPrimary,
    brightness: Brightness.dark, // Modern dark theme
  );

  static TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      fontFamily: 'Parkinsans',
      color: AppColors.onBackground, // Modern vibrant text
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      fontFamily: 'Parkinsans',
      color: AppColors.onBackground,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      fontFamily: 'Parkinsans',
      color: AppColors.onBackground,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      fontFamily: 'Parkinsans',
      color: AppColors.onBackground,
    ),
  );

  static ThemeData themeData = ThemeData(
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: colorScheme.background, // App background
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.primary, // Modern AppBar
      foregroundColor: colorScheme.onPrimary, // Text/icon color in AppBar
      titleTextStyle: textTheme.titleMedium,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.secondary, // Button background
        foregroundColor: colorScheme.onSecondary, // Button text/icon color
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        textStyle: textTheme.labelLarge,
      ),
    ),
    cardColor: colorScheme.surface, // Modern card color
    dialogBackgroundColor: colorScheme.surface, // Dialog background
  );
}
