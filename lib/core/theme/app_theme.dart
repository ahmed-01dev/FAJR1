/// Light + dark Material 3 themes built from the design tokens.
library core.theme;

import 'package:flutter/material.dart';
import 'tokens.dart';

/// Build the light theme.
ThemeData buildLightTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.deepGreen,
    brightness: Brightness.light,
  );
  return _base(scheme, AppColors.textOnLight);
}

/// Build the dark theme (default visual identity of the app).
ThemeData buildDarkTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.deepGreen,
    brightness: Brightness.dark,
  ).copyWith(surface: AppColors.darkSurface, primary: AppColors.gold);
  return _base(scheme, AppColors.textOnDark);
}

ThemeData _base(ColorScheme scheme, Color textColor) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor:
        scheme.brightness == Brightness.dark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
    fontFamily: 'NotoNaskhArabic',
    textTheme: _textTheme(textColor),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: textColor,
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: scheme.outlineVariant, width: 0.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        minimumSize: const Size(64, 48),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

TextTheme _textTheme(Color color) => TextTheme(
  headlineMedium: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: color,
  ),
  titleLarge: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: color,
  ),
  titleMedium: TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: color,
  ),
  bodyLarge: TextStyle(fontSize: 16, height: 1.7, color: color),
  bodyMedium: TextStyle(fontSize: 14, height: 1.7, color: color),
  labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
);
