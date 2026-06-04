import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.gold,
      secondary: AppColors.gold,
      onSecondary: AppColors.onPrimary,
      secondaryContainer: AppColors.goldLight,
      onSecondaryContainer: Color(0xFF785D00),
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      error: AppColors.error,
      onError: AppColors.onPrimary,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.w700,
        height: 1.24,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.48,
      ),
      bodyLarge: TextStyle(fontSize: 18, height: 1.56),
      bodyMedium: TextStyle(fontSize: 16, height: 1.5),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
      ),
    ),

    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background.withOpacity(0.9),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.gold,
      unselectedItemColor: AppColors.outline,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );

  static ThemeData get dark => light.copyWith(
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFA5D0B9),
      onPrimary: Color(0xFF002114),
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.gold,
      secondary: AppColors.goldDim,
      onSecondary: Color(0xFF241A00),
      secondaryContainer: Color(0xFF584400),
      onSecondaryContainer: AppColors.goldLight,
      surface: Color(0xFF1A2E24),
      onSurface: Color(0xFFE5E2DB),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
    ),
  );
}
