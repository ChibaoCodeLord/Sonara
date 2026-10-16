import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand palette
  static const Color primary = Color(0xFF9A1B2F);
  static const Color primaryContainer = Color(0xFFB3122E);
  static const Color primaryFixed = Color(0xFFFFDAD9);
  static const Color primaryFixedDim = Color(0xFFFFB3B3);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Secondary & Accents
  static const Color secondary = Color(0xFFBB0015);
  static const Color secondaryFixed = Color(0xFFFFDAD6);
  static const Color secondaryContainer = Color(0xFFE9091F);
  static const Color secondaryFixedDim = Color(0xFFFFB4AC);
  static const Color tertiary = Color(0xFF8B0012);
  static const Color emeraldActive = Color(0xFF10B981);

  // AI Gradient tokens
  static const Color aiGradientStart = Color(0xFFB3122E);
  static const Color aiGradientEnd = Color(0xFFFF4B4B);

  static const LinearGradient aiGradient = LinearGradient(
    colors: [aiGradientStart, primary, aiGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFFB3122E), Color(0xFF8B001E), Color(0xFFFF4B4B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient miniPlayerProgressGradient = LinearGradient(
    colors: [aiGradientStart, aiGradientEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Surface & Neutrals (Warm Ivory System)
  static const Color surface = Color(0xFFFAF8F6);
  static const Color surfaceIvory = Color(0xFFFAF8F6);
  static const Color surfaceCrisp = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFEFEDEC);
  static const Color surfaceContainerLow = Color(0xFFF5F3F1);
  static const Color surfaceContainerHigh = Color(0xFFEAE8E6);
  static const Color surfaceContainerHighest = Color(0xFFE4E2E0);
  static const Color surfaceDim = Color(0xFFDBDAD8);

  // Text & Content
  static const Color textCharcoal = Color(0xFF1A1A1A);
  static const Color onSurface = Color(0xFF1B1C1B);
  static const Color textMuted = Color(0xFF71747B);
  static const Color textSecondary = Color(0xFF62656B);

  // Borders & Dividers
  static const Color borderSubtle = Color(0xFFF0ECE9);
  static const Color borderMuted = Color(0xFFE5E1DD);

  // Glow & FX
  static const Color waveformGlow = Color(0x40E4001C);
  static const Color shadowColor = Color(0x0F000000);
}
