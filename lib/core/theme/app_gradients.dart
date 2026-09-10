import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Sophisticated, curated Warm Premium gradients for AI CareerPilot.
class AppGradients {
  /// Primary warm tactile button gradient
  static LinearGradient get primaryButton => LinearGradient(
        colors: [AppColors.primary, AppColors.accent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Deep Slate hero card gradient
  static LinearGradient get walnutHero => const LinearGradient(
        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Primary warm accent gradient
  static LinearGradient get heroGradient => LinearGradient(
        colors: [AppColors.primary, AppColors.softTerracotta],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Warm Amber gradient
  static LinearGradient get amberGradient => LinearGradient(
        colors: [AppColors.warning, AppColors.softAmber],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Sage Green accent gradient
  static LinearGradient get sageGradient => LinearGradient(
        colors: [AppColors.secondary, AppColors.softSage],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Signature AI feature glow background gradient
  static LinearGradient get aiGlowGradient => LinearGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.14),
          AppColors.accent.withValues(alpha: 0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Subtle card background gradient
  static LinearGradient get warmCard => LinearGradient(
        colors: [AppColors.surface, AppColors.surfaceSecondary],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  /// Subtle ambient glow radial gradient
  static RadialGradient ambientGlow(Color color, [double opacity = 0.10]) =>
      RadialGradient(
        colors: [color.withValues(alpha: opacity), Colors.transparent],
      );
}
