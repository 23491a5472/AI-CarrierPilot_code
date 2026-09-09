import 'package:flutter/material.dart';

abstract class AppThemePreset {
  Color get primary;
  Color get secondary;
  Color get accent;
  Color get success;
  Color get warning;
  Color get error;
  Color get background;
  Color get bgSecondary;
  Color get mutedCoral;
  Color get dustyRose;
  Color get softPeach;
  Color get warmBeige;
  Color get textPrimary;
  Color get textSecondary;
  Color get textLight;
  Color get textInverse;
}

class AppleHeadspaceTheme implements AppThemePreset {
  @override Color get primary => const Color(0xFF6B4F3A); // Walnut Brown
  @override Color get secondary => const Color(0xFFD97757); // Warm Terracotta
  @override Color get accent => const Color(0xFFF2B84B); // Golden Amber
  @override Color get success => const Color(0xFF5E8B65); // Sage Green
  @override Color get warning => const Color(0xFFD97757);
  @override Color get error => const Color(0xFFC95E5E);
  @override Color get background => const Color(0xFFFFF9F3);
  @override Color get bgSecondary => const Color(0xFFF8F4EE);
  @override Color get mutedCoral => const Color(0xFFE49B89);
  @override Color get dustyRose => const Color(0xFFD49A9A);
  @override Color get softPeach => const Color(0xFFFFE0D2);
  @override Color get warmBeige => const Color(0xFFF2EADF);
  @override Color get textPrimary => const Color(0xFF2C2723);
  @override Color get textSecondary => const Color(0xFF7A6F66);
  @override Color get textLight => const Color(0xFFB0A79E);
  @override Color get textInverse => Colors.white;
}

class PurplePremiumTheme implements AppThemePreset {
  @override Color get primary => const Color(0xFF3B2C5A); // Deep Royal Purple
  @override Color get secondary => const Color(0xFF8B5A9C); // Soft Amethyst
  @override Color get accent => const Color(0xFFE0C4F8); // Luminous Lavender
  @override Color get success => const Color(0xFF4A9E78); 
  @override Color get warning => const Color(0xFFDDA65B);
  @override Color get error => const Color(0xFFC44D56);
  @override Color get background => const Color(0xFFF8F5FB); // Soft Lilac Cream
  @override Color get bgSecondary => const Color(0xFFEBE6F3);
  @override Color get mutedCoral => const Color(0xFFA58EBA);
  @override Color get dustyRose => const Color(0xFFC1B0D6);
  @override Color get softPeach => const Color(0xFFE6DDF0);
  @override Color get warmBeige => const Color(0xFFDCD2E7);
  @override Color get textPrimary => const Color(0xFF211933);
  @override Color get textSecondary => const Color(0xFF63567D);
  @override Color get textLight => const Color(0xFF9E92B3);
  @override Color get textInverse => Colors.white;
}

class EmeraldTheme implements AppThemePreset {
  @override Color get primary => const Color(0xFF1E4631); // Deep Emerald
  @override Color get secondary => const Color(0xFF42805E); // Mint Forest
  @override Color get accent => const Color(0xFFB5E2C9); // Soft Jade
  @override Color get success => const Color(0xFF388E3C);
  @override Color get warning => const Color(0xFFFBC02D);
  @override Color get error => const Color(0xFFD32F2F);
  @override Color get background => const Color(0xFFF4FAF6);
  @override Color get bgSecondary => const Color(0xFFE4F3E9);
  @override Color get mutedCoral => const Color(0xFF7CB696);
  @override Color get dustyRose => const Color(0xFFA1D1B7);
  @override Color get softPeach => const Color(0xFFCEECD9);
  @override Color get warmBeige => const Color(0xFFBEE4CC);
  @override Color get textPrimary => const Color(0xFF132D20);
  @override Color get textSecondary => const Color(0xFF456B55);
  @override Color get textLight => const Color(0xFF86A592);
  @override Color get textInverse => Colors.white;
}

class RoyalGoldTheme implements AppThemePreset {
  @override Color get primary => const Color(0xFF1F2229); // Onyx Black
  @override Color get secondary => const Color(0xFFC5A059); // Champagne Gold
  @override Color get accent => const Color(0xFFEBD29F); // Bright Gold
  @override Color get success => const Color(0xFF4CAF50);
  @override Color get warning => const Color(0xFFFF9800);
  @override Color get error => const Color(0xFFF44336);
  @override Color get background => const Color(0xFFFAFAFA);
  @override Color get bgSecondary => const Color(0xFFF0F0F0);
  @override Color get mutedCoral => const Color(0xFFD4B986);
  @override Color get dustyRose => const Color(0xFFE2CFA9);
  @override Color get softPeach => const Color(0xFFF1E6CD);
  @override Color get warmBeige => const Color(0xFFEAEAEA);
  @override Color get textPrimary => const Color(0xFF1A1A1A);
  @override Color get textSecondary => const Color(0xFF666666);
  @override Color get textLight => const Color(0xFFAAAAAA);
  @override Color get textInverse => Colors.white;
}

// Global Theme Switcher
class AppTheme {
  // To switch the entire app's theme, just change this instance!
  static AppThemePreset current = AppleHeadspaceTheme();
  
  // Future implementation: Add ValueNotifier or Riverpod provider here 
  // so switching themes triggers a reactive UI rebuild.
}
