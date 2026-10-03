import 'package:flutter/material.dart';

/// Central visual tokens for the Snap Foodd admin web application.
///
/// Keep semantic status colors separate from brand colors so operational
/// meaning remains predictable across tables, forms, feedback and dashboards.
abstract final class AdminDesignColors {
  static const brandYellow = Color(0xFFF2D022);
  static const brandAmber = Color(0xFFF2AE2E);
  static const deepRed = Color(0xFFA61C1C);
  static const foodRed = Color(0xFFD92929);
  static const ink = Color(0xFF0D0D0D);

  static const canvas = Color(0xFFF7F7F5);
  static const surface = Color(0xFFFFFFFF);
  static const subtleSurface = Color(0xFFFAFAF8);
  static const border = Color(0xFFE7E7E2);
  static const primaryText = Color(0xFF171717);
  static const secondaryText = Color(0xFF6B6B67);
  static const tertiaryText = Color(0xFF999993);

  static const success = Color(0xFF16803C);
  static const warning = Color(0xFFB7791F);
  static const error = Color(0xFFC53030);
  static const info = Color(0xFF2563EB);

  static const successSoft = Color(0x1416803C);
  static const warningSoft = Color(0x14B7791F);
  static const errorSoft = Color(0x14C53030);
  static const infoSoft = Color(0x142563EB);
  static const yellowSoft = Color(0x14F2D022);
  static const amberSoft = Color(0x14F2AE2E);
  static const redSoft = Color(0x14D92929);
}
