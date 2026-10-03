import 'package:flutter/material.dart';

/// Centralized typography tokens for the Snap Foodd customer experience.
///
/// The family name intentionally matches the product type system. The current
/// repository does not bundle font files, so Flutter will use its platform
/// fallback until Plus Jakarta Sans is supplied as an app asset.
abstract final class SnapFoodTypography {
  static const fontFamily = 'Plus Jakarta Sans';

  static const displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    height: 48 / 40,
    fontWeight: FontWeight.w800,
  );

  static const displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w700,
  );

  static const displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    height: 32 / 26,
    fontWeight: FontWeight.w700,
  );

  static const headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 30 / 24,
    fontWeight: FontWeight.w700,
  );

  static const headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w700,
  );

  static const titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
  );

  static const titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
  );

  static const titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
  );

  static const bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 24 / 16,
  );

  static const bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 20 / 14,
  );

  static const bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 16 / 12,
  );

  static const labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 18 / 14,
    fontWeight: FontWeight.w700,
  );

  static const labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w700,
  );

  static const labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w600,
  );
}
