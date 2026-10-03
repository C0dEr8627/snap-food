import 'package:flutter/material.dart';

abstract final class AdminTypography {
  static const fontFamily = 'Inter';

  static const display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    height: 1.15,
    fontWeight: FontWeight.w700,
    color: Color(0xFF171717),
  );

  static const pageTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: Color(0xFF171717),
  );

  static const sectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    height: 1.25,
    fontWeight: FontWeight.w600,
    color: Color(0xFF171717),
  );

  static const cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: Color(0xFF171717),
  );

  static const body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: Color(0xFF171717),
  );

  static const small = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w500,
    color: Color(0xFF6B6B67),
  );

  static const caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w500,
    color: Color(0xFF999993),
  );

  static TextTheme get textTheme => const TextTheme(
    displayLarge: display,
    headlineLarge: pageTitle,
    headlineSmall: sectionTitle,
    titleMedium: cardTitle,
    bodyLarge: body,
    bodyMedium: body,
    bodySmall: small,
    labelSmall: caption,
  );
}
