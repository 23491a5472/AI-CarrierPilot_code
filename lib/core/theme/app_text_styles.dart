import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Editorial typography system for AI CareerPilot Warm Premium UI.
///
/// Uses Inter via Google Fonts with clear visual hierarchy,
/// distinct font weights, and letter-spacing for editorial elegance.
class AppTextStyles {
  // ── Display & Editorial Anchors ──
  static TextStyle get display => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.6,
        height: 1.2,
      );

  // ── Headings ──
  static TextStyle get h1 => TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.4,
        height: 1.25,
      );

  static TextStyle get h2 => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
        height: 1.3,
      );

  static TextStyle get h3 => TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.1,
        height: 1.35,
      );

  static TextStyle get h4 => TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  // ── Body ──
  static TextStyle get bodyLarge => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
        height: 1.5,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
        height: 1.5,
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        letterSpacing: 0.1,
        height: 1.5,
      );

  // ── Labels & Eyebrows ──
  static TextStyle get labelText => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.1,
      );

  static TextStyle get label => labelText;
  static TextStyle get labelMedium => labelText;

  static TextStyle get caption => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
        letterSpacing: 0.2,
        height: 1.4,
      );

  static TextStyle get overline => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 1.1,
        height: 1.4,
      );

  // ── Buttons ──
  static TextStyle get buttonText => TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textInverse,
        letterSpacing: 0.2,
      );

  // ── Metric Displays & Numbers ──
  static TextStyle get scoreLarge => TextStyle(
        fontSize: 52,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -1.2,
        height: 1.0,
      );

  static TextStyle get scoreMedium => TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.6,
        height: 1.0,
      );

  static TextStyle get tag => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        height: 1.3,
      );
}
