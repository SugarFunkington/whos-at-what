import 'package:app/ui/core/themes/colors.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryBlock,
    onPrimaryContainer: AppColors.ink,
    secondary: AppColors.ink,
    onSecondary: AppColors.surface,
    tertiary: AppColors.wholeFamily,
    tertiaryContainer: AppColors.wholeFamilySoft,
    error: AppColors.error,
    onError: AppColors.onPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
    onSurfaceVariant: AppColors.muted,
    surfaceContainerLowest: AppColors.background,
    surfaceContainerLow: AppColors.eventCard,
    outline: AppColors.outline,
    outlineVariant: AppColors.divider,
  );

  // Weights carry the hierarchy. Colour is ink unless the style is muted.
  static const _textTheme = TextTheme(
    headlineMedium: TextStyle(
      fontSize: 29,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.9,
      height: 1.05,
      color: AppColors.ink,
    ),
    titleLarge: TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w800,
      color: AppColors.ink,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      color: AppColors.ink,
    ),
    titleSmall: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w800,
      color: AppColors.ink,
    ),
    bodyLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.25,
      color: AppColors.ink,
    ),
    bodyMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: AppColors.muted,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.muted,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: AppColors.ink,
    ),
    labelMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: AppColors.muted,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: AppColors.ink,
    ),
  );

  static final lightTheme = ThemeData(
    colorScheme: _colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Manrope',
    textTheme: _textTheme,
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),
  );
}
