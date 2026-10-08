import 'package:flutter/material.dart';

/// The raw palette. Only `theme.dart` uses these; widgets read colours from
/// `Theme.of(context).colorScheme`.
abstract final class AppColors {
  static const primary = Color(0xFF137A6B);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryBlock = Color(0xFFCFE8E2);
  static const ink = Color(0xFF1D2B2A);
  static const muted = Color(0xFF62716F);
  static const background = Color(0xFFFBFAF7);
  static const surface = Color(0xFFFFFFFF);
  static const eventCard = Color(0xFFEEF5F2);
  static const outline = Color(0xFFDCE6E2);
  static const divider = Color(0xFFEEF1EF);
  static const error = Color(0xFFC8442E);

  /// Events for the whole family.
  static const wholeFamily = Color(0xFFB07CFF);
  static const wholeFamilySoft = Color(0xFFEFE4FF);
}
