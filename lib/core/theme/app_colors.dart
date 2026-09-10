import 'package:flutter/material.dart';
import 'theme_presets.dart';

/// Centralized color tokens for AI CareerPilot Warm Premium Design System.
/// All values are dynamic getters backed by the active [AppThemePreset].
class AppColors {
  // ── Brand ──
  static Color get primary        => AppTheme.current.primary;
  static Color get primaryDark    => AppTheme.current.primaryDark;
  static Color get accent         => AppTheme.current.accent;
  static Color get secondary      => AppTheme.current.secondary;
  static Color get deepWalnut     => AppTheme.current.deepWalnut;

  // ── Surfaces ──
  static Color get background     => AppTheme.current.background;
  static Color get surface        => AppTheme.current.surface;
  static Color get surfaceSecondary => AppTheme.current.surfaceSecondary;
  static Color get cardBackground => AppTheme.current.surface;

  // ── Soft Tints (card backgrounds & visual accents) ──
  static Color get softTerracotta => AppTheme.current.softTerracotta;
  static Color get softAmber      => AppTheme.current.softAmber;
  static Color get softSage       => AppTheme.current.softSage;

  // ── Signature AI Tokens ──
  static Color get aiGlow         => AppTheme.current.primary.withValues(alpha: 0.16);
  static Color get aiBadgeBg      => AppTheme.current.softTerracotta.withValues(alpha: 0.25);
  static Color get aiAccent       => AppTheme.current.accent;

  // ── Text ──
  static Color get textPrimary    => AppTheme.current.textPrimary;
  static Color get textSecondary  => AppTheme.current.textSecondary;
  static Color get textMuted      => AppTheme.current.textMuted;
  static Color get textInverse    => AppTheme.current.textInverse;

  // ── Semantic ──
  static Color get success        => AppTheme.current.success;
  static Color get warning        => AppTheme.current.warning;
  static Color get error          => AppTheme.current.error;

  // ── Structural ──
  static Color get border         => AppTheme.current.border;
  static Color get divider        => AppTheme.current.divider;

  // ── Legacy / Compatibility Getters ──
  static Color get mutedCoral     => AppTheme.current.mutedCoral;
  static Color get dustyRose      => AppTheme.current.dustyRose;
  static Color get warmBeige      => AppTheme.current.warmBeige;
  static Color get bgSecondary    => AppTheme.current.bgSecondary;
  static Color get textLight      => AppTheme.current.textLight;
}
