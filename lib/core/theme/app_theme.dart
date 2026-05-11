import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        surface: AppColors.surface,
        primary: AppColors.primary,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        hintStyle: const TextStyle(
          color: AppColors.textHint,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide:
              const BorderSide(color: AppColors.inputBorderFocused, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),

      // Elevated Button (used for the send button)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.userBubbleText,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(12),
          elevation: 0,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // Typography
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          fontSize: 15,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          color: AppColors.textHint,
        ),
      ),
    );
  }
}
