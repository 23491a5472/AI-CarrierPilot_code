import 'package:flutter/material.dart';

/// Design token contract for AI CareerPilot Warm Premium theme.
abstract class AppThemePreset {
  bool get isDarkMode;

  Color get primary;
  Color get primaryDark;
  Color get accent;
  Color get secondary;
  Color get deepWalnut;

  Color get background;
  Color get surface;
  Color get surfaceSecondary;

  Color get softTerracotta;
  Color get softAmber;
  Color get softSage;

  Color get textPrimary;
  Color get textSecondary;
  Color get textMuted;
  Color get textInverse;

  Color get success;
  Color get warning;
  Color get error;

  Color get border;
  Color get divider;

  // Fallbacks for older token names for backwards compatibility
  Color get mutedCoral => softTerracotta;
  Color get dustyRose => softTerracotta;
  Color get warmBeige => surfaceSecondary;
  Color get bgSecondary => surfaceSecondary;
  Color get textLight => textMuted;
}

/// Technical Slate & Charcoal Dark Mode Theme.
class TechnicalSlateDarkTheme implements AppThemePreset {
  @override bool get isDarkMode => true;

  @override Color get primary        => const Color(0xFFFF6B6B); // Electric Coral
  @override Color get primaryDark    => const Color(0xFFBE123C); // Deep Crimson Coral
  @override Color get accent         => const Color(0xFFF59E0B); // Muted Amber Gold Accent
  @override Color get secondary      => const Color(0xFF14B8A6); // Electric Teal Secondary
  @override Color get deepWalnut     => const Color(0xFF0F172A); // Deep Slate Hero Canvas

  @override Color get background     => const Color(0xFF0F172A); // Deep Slate Dark Canvas
  @override Color get surface        => const Color(0xFF1E293B); // Dark Slate Card Container
  @override Color get surfaceSecondary => const Color(0xFF334155); // Soft Charcoal Slate Layer

  @override Color get softTerracotta => const Color(0xFFFF6B6B); // Electric Coral Glow Tint
  @override Color get softAmber      => const Color(0xFF3B2D19); // Muted Amber Glow Tint
  @override Color get softSage       => const Color(0xFF132A29); // Soft Electric Teal Glow Tint

  @override Color get textPrimary    => const Color(0xFFF8FAFC); // High-Contrast Off-White
  @override Color get textSecondary  => const Color(0xFF94A3B8); // Soft Slate Blue Grey
  @override Color get textMuted      => const Color(0xFF64748B); // Muted Slate
  @override Color get textInverse    => const Color(0xFF0F172A); // Dark Slate Inverse

  @override Color get success        => const Color(0xFF10B981); // Electric Teal Green
  @override Color get warning        => const Color(0xFFF59E0B); // Muted Amber Gold
  @override Color get error          => const Color(0xFFFF6B6B); // Electric Coral Alert

  @override Color get border         => const Color(0xFF334155); // Crisp Dark Slate Border
  @override Color get divider        => const Color(0xFF1E293B); // Tonal Line Divider

  @override Color get mutedCoral     => const Color(0xFFFF6B6B);
  @override Color get dustyRose      => const Color(0xFFFF6B6B);
  @override Color get warmBeige      => const Color(0xFF334155);
  @override Color get bgSecondary    => const Color(0xFF334155);
  @override Color get textLight      => const Color(0xFF64748B);
}

/// Quartz & Mint Light Mode Theme.
class QuartzMintLightTheme implements AppThemePreset {
  @override bool get isDarkMode => false;

  @override Color get primary        => const Color(0xFF0D9488); // Modern Teal / Mint Cyan
  @override Color get primaryDark    => const Color(0xFF115E59); // Deep Forest Teal
  @override Color get accent         => const Color(0xFF14B8A6); // Fresh Mint Accent
  @override Color get secondary      => const Color(0xFF319795); // Deep Mint Secondary
  @override Color get deepWalnut     => const Color(0xFF0F172A); // Rich Dark Charcoal / Slate

  @override Color get background     => const Color(0xFFF7FAFC); // Clean Quartz White Canvas
  @override Color get surface        => const Color(0xFFFFFFFF); // Pure Crisp White Cards
  @override Color get surfaceSecondary => const Color(0xFFEDF2F7); // Soft Quartz Layer

  @override Color get softTerracotta => const Color(0xFFFF6F61); // Deep Coral Alert Glow
  @override Color get softAmber      => const Color(0xFFFEF3C7); // Soft Muted Amber
  @override Color get softSage       => const Color(0xFFE6FFFA); // Fresh Mint Green Glow

  @override Color get textPrimary    => const Color(0xFF1A202C); // Rich Slate Charcoal
  @override Color get textSecondary  => const Color(0xFF4A5568); // Slate Grey
  @override Color get textMuted      => const Color(0xFF718096); // Muted Slate
  @override Color get textInverse    => Colors.white;

  @override Color get success        => const Color(0xFF4FD1C5); // Fresh Mint Green
  @override Color get warning        => const Color(0xFFF59E0B); // Muted Amber Gold
  @override Color get error          => const Color(0xFFFF6F61); // Deep Coral Red

  @override Color get border         => const Color(0xFFE2E8F0); // Soft Quartz Border
  @override Color get divider        => const Color(0xFFEDF2F7); // Tonal Line Divider

  @override Color get mutedCoral     => const Color(0xFFFF6F61);
  @override Color get dustyRose      => const Color(0xFFFF6F61);
  @override Color get warmBeige      => const Color(0xFFEDF2F7);
  @override Color get bgSecondary    => const Color(0xFFEDF2F7);
  @override Color get textLight      => const Color(0xFF718096);
}

/// Alias for backwards compatibility.
typedef WarmCareerTheme = TechnicalSlateDarkTheme;

/// Compatibility theme classes for state persisted across hot reloads.
class AppleHeadspaceTheme extends TechnicalSlateDarkTheme {}
class PurplePremiumTheme extends TechnicalSlateDarkTheme {}
class EmeraldTheme extends TechnicalSlateDarkTheme {}
class RoyalGoldTheme extends TechnicalSlateDarkTheme {}

/// Global theme switcher.
class AppTheme {
  static AppThemePreset current = TechnicalSlateDarkTheme();
}
