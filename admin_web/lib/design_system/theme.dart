import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import 'colors.dart';
import 'radii.dart';
import 'typography.dart';

abstract final class AdminTheme {
  static ThemeData material() => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AdminDesignColors.brandYellow,
      brightness: Brightness.light,
    ).copyWith(
      primary: AdminDesignColors.ink,
      onPrimary: AdminDesignColors.surface,
      secondary: AdminDesignColors.brandAmber,
      onSecondary: AdminDesignColors.ink,
      error: AdminDesignColors.error,
      onError: AdminDesignColors.surface,
      surface: AdminDesignColors.surface,
      onSurface: AdminDesignColors.primaryText,
    ),
    scaffoldBackgroundColor: AdminDesignColors.canvas,
    textTheme: AdminTypography.textTheme,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AdminDesignColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AdminRadii.input),
        borderSide: const BorderSide(color: AdminDesignColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AdminRadii.input),
        borderSide: const BorderSide(color: AdminDesignColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AdminRadii.input),
        borderSide: const BorderSide(color: AdminDesignColors.ink, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    ),
    useMaterial3: true,
  );

  static shad.ThemeData shadcn() => shad.ThemeData(
    colorScheme: shad.LegacyColorSchemes.lightZinc(),
    radius: AdminRadii.card / 16,
  );
}
