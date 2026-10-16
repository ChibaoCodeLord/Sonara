import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get displayLg => GoogleFonts.plusJakartaSans(
        fontSize: 40,
        height: 48 / 40,
        letterSpacing: -0.03 * 40,
        fontWeight: FontWeight.w800,
        color: AppColors.textCharcoal,
      );

  static TextStyle get displayLgMobile => GoogleFonts.plusJakartaSans(
        fontSize: 32,
        height: 40 / 32,
        letterSpacing: -0.02 * 32,
        fontWeight: FontWeight.w800,
        color: AppColors.textCharcoal,
      );

  static TextStyle get headlineLg => GoogleFonts.plusJakartaSans(
        fontSize: 28,
        height: 36 / 28,
        letterSpacing: -0.02 * 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textCharcoal,
      );

  static TextStyle get headlineMd => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        height: 28 / 22,
        letterSpacing: -0.015 * 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textCharcoal,
      );

  static TextStyle get headlineSm => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        height: 24 / 18,
        letterSpacing: -0.01 * 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textCharcoal,
      );

  static TextStyle get bodyLg => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        height: 24 / 16,
        letterSpacing: -0.005 * 16,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyMd => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        height: 20 / 14,
        letterSpacing: 0,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      );

  static TextStyle get bodySm => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        height: 16 / 12,
        letterSpacing: 0.01 * 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      );

  static TextStyle get labelLg => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        height: 18 / 14,
        letterSpacing: 0.01 * 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textCharcoal,
      );

  static TextStyle get labelMd => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        height: 16 / 12,
        letterSpacing: 0.02 * 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textCharcoal,
      );

  static TextStyle get labelSm => GoogleFonts.plusJakartaSans(
        fontSize: 10,
        height: 12 / 10,
        letterSpacing: 0.04 * 10,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
      );
}
