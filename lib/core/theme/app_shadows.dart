import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Soft dimensional shadow system for AI CareerPilot.
/// Provides visual depth without dark heavy borders.
class AppShadows {
  /// Default card shadow — soft dimensional lift.
  static List<BoxShadow> get card => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  /// Floating/active card shadow — soft elevated depth.
  static List<BoxShadow> get cardHover => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  /// Primary action button shadow with warm accent ambient light.
  static List<BoxShadow> get button => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.22),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ];

  /// Signature AI visual element ambient glow.
  static List<BoxShadow> get aiGlow => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.16),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];

  /// Soft floating bottom navigation bar shadow.
  static List<BoxShadow> get navigation => [
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.06),
          blurRadius: 20,
          offset: const Offset(0, -4),
        ),
      ];
}
