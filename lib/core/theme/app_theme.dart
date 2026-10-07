import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Tema completo de Trama (claro y oscuro).
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBackground,
        colorScheme: const ColorScheme.light(
          surface: AppColors.lightSurface,
          primary: AppColors.accent,
          onPrimary: Colors.white,
          onSurface: AppColors.lightTextPrimary,
          outline: AppColors.lightBorder,
        ),
        textTheme: TextTheme(
          bodyLarge: AppTypography.bodyLarge.copyWith(
            color: AppColors.lightTextPrimary,
          ),
          bodyMedium: AppTypography.bodyMedium.copyWith(
            color: AppColors.lightTextSecondary,
          ),
          bodySmall: AppTypography.bodySmall.copyWith(
            color: AppColors.lightTextSecondary,
          ),
          displayLarge: AppTypography.displayLarge.copyWith(
            color: AppColors.lightTextPrimary,
          ),
          displayMedium: AppTypography.displayMedium.copyWith(
            color: AppColors.lightTextPrimary,
          ),
          headlineLarge: AppTypography.headingLarge.copyWith(
            color: AppColors.lightTextPrimary,
          ),
          headlineMedium: AppTypography.headingMedium.copyWith(
            color: AppColors.lightTextPrimary,
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: const ColorScheme.dark(
          surface: AppColors.darkSurface,
          primary: AppColors.accentDark,
          onPrimary: Colors.black,
          onSurface: AppColors.darkTextPrimary,
          outline: AppColors.darkBorder,
        ),
        textTheme: TextTheme(
          bodyLarge: AppTypography.bodyLarge.copyWith(
            color: AppColors.darkTextPrimary,
          ),
          bodyMedium: AppTypography.bodyMedium.copyWith(
            color: AppColors.darkTextSecondary,
          ),
          bodySmall: AppTypography.bodySmall.copyWith(
            color: AppColors.darkTextSecondary,
          ),
          displayLarge: AppTypography.displayLarge.copyWith(
            color: AppColors.darkTextPrimary,
          ),
          displayMedium: AppTypography.displayMedium.copyWith(
            color: AppColors.darkTextPrimary,
          ),
          headlineLarge: AppTypography.headingLarge.copyWith(
            color: AppColors.darkTextPrimary,
          ),
          headlineMedium: AppTypography.headingMedium.copyWith(
            color: AppColors.darkTextPrimary,
          ),
        ),
      );
}