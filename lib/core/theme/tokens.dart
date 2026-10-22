/// Design tokens — single source of truth for the visual identity (§6).
///
/// Deep green + warm gold on elegant dark backgrounds, calm and
/// professional. No visual value is hand-duplicated in screens.
library core.theme;

import 'package:flutter/material.dart';

/// Brand color palette.
abstract final class AppColors {
  static const deepGreen = Color(0xFF0E3B2E);
  static const deepGreenDark = Color(0xFF092A20);
  static const gold = Color(0xFFD4AF6A);
  static const goldSoft = Color(0xFFE8CD9E);
  static const darkBackground = Color(0xFF12171A);
  static const darkSurface = Color(0xFF1B2226);
  static const lightBackground = Color(0xFFF8F6F1);
  static const lightSurface = Color(0xFFFFFFFF);
  static const textOnDark = Color(0xFFEDE9E1);
  static const textOnLight = Color(0xFF1C2A24);
  static const errorRed = Color(0xFFCF6679);
}

/// Spacing scale (4pt grid).
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

/// Corner radii.
abstract final class AppRadius {
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const pill = 999.0;
}

/// Motion durations — short, non-distracting (§6).
abstract final class AppMotion {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
}
