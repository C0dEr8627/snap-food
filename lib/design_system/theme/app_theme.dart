import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_radii.dart';

abstract final class SnapFoodTheme {
  static const _fontFamily = 'Plus Jakarta Sans';

  static ThemeData get light {
    final scheme = ColorScheme(
      brightness: Brightness.light,
      primary: SnapFoodColors.primary, onPrimary: SnapFoodColors.onPrimary,
      primaryContainer: SnapFoodColors.primaryContainer, onPrimaryContainer: SnapFoodColors.warmBlack,
      secondary: SnapFoodColors.secondary, onSecondary: SnapFoodColors.onSecondary,
      secondaryContainer: SnapFoodColors.secondaryContainer, onSecondaryContainer: SnapFoodColors.onPrimary,
      tertiary: SnapFoodColors.tertiary, onTertiary: SnapFoodColors.onPrimary,
      tertiaryContainer: SnapFoodColors.tertiaryContainer, onTertiaryContainer: SnapFoodColors.warmBlack,
      error: SnapFoodColors.error, onError: SnapFoodColors.onPrimary,
      surface: SnapFoodColors.surface, onSurface: SnapFoodColors.onSurface,
      surfaceContainerLowest: SnapFoodColors.surfaceContainerLowest,
      surfaceContainerLow: SnapFoodColors.surfaceContainerLow,
      surfaceContainer: SnapFoodColors.surfaceContainer,
      surfaceContainerHigh: SnapFoodColors.surfaceContainerHigh,
      surfaceContainerHighest: SnapFoodColors.surfaceContainerHighest,
      onSurfaceVariant: SnapFoodColors.onSurfaceVariant,
      outline: SnapFoodColors.outline, outlineVariant: SnapFoodColors.outlineVariant,
      inverseSurface: SnapFoodColors.warmBlack, onInverseSurface: SnapFoodColors.surfaceContainerLowest,
      inversePrimary: SnapFoodColors.primaryContainer,
    );
    const textTheme = TextTheme(
      displayLarge: TextStyle(fontFamily: _fontFamily, fontSize: 40, height: 48 / 40, fontWeight: FontWeight.w800),
      displayMedium: TextStyle(fontFamily: _fontFamily, fontSize: 32, height: 40 / 32, fontWeight: FontWeight.w700),
      displaySmall: TextStyle(fontFamily: _fontFamily, fontSize: 26, height: 32 / 26, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(fontFamily: _fontFamily, fontSize: 24, height: 30 / 24, fontWeight: FontWeight.w700),
      headlineSmall: TextStyle(fontFamily: _fontFamily, fontSize: 20, height: 26 / 20, fontWeight: FontWeight.w700),
      titleLarge: TextStyle(fontFamily: _fontFamily, fontSize: 18, height: 24 / 18, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontFamily: _fontFamily, fontSize: 16, height: 22 / 16, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontFamily: _fontFamily, fontSize: 16, height: 24 / 16),
      bodyMedium: TextStyle(fontFamily: _fontFamily, fontSize: 14, height: 20 / 14),
      bodySmall: TextStyle(fontFamily: _fontFamily, fontSize: 12, height: 16 / 12),
      labelLarge: TextStyle(fontFamily: _fontFamily, fontSize: 14, height: 18 / 14, fontWeight: FontWeight.w700),
      labelMedium: TextStyle(fontFamily: _fontFamily, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w700),
      labelSmall: TextStyle(fontFamily: _fontFamily, fontSize: 11, height: 14 / 11, fontWeight: FontWeight.w600),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: SnapFoodColors.surface,
      fontFamily: _fontFamily,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: SnapFoodColors.surfaceContainerLowest, elevation: 0, margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SnapFoodRadii.lg), side: const BorderSide(color: SnapFoodColors.softBorder)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: SnapFoodColors.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(SnapFoodRadii.md), borderSide: const BorderSide(color: SnapFoodColors.softBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(SnapFoodRadii.md), borderSide: const BorderSide(color: SnapFoodColors.softBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(SnapFoodRadii.md), borderSide: const BorderSide(color: SnapFoodColors.goldenYellow, width: 1.5)),
      ),
    );
  }
}
