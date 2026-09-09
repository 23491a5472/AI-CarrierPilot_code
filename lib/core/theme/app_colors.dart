import 'package:flutter/material.dart';
import 'theme_presets.dart';

class AppColors {
  // All colors are now dynamic getters reading from the active theme preset
  static Color get primary => AppTheme.current.primary;
  static Color get secondary => AppTheme.current.secondary;
  static Color get accent => AppTheme.current.accent;
  
  static Color get success => AppTheme.current.success;
  static Color get warning => AppTheme.current.warning;
  static Color get error => AppTheme.current.error;

  static Color get background => AppTheme.current.background;
  static Color get bgSecondary => AppTheme.current.bgSecondary;
  
  static Color get mutedCoral => AppTheme.current.mutedCoral;
  static Color get dustyRose => AppTheme.current.dustyRose;
  static Color get softPeach => AppTheme.current.softPeach;
  static Color get warmBeige => AppTheme.current.warmBeige;
  
  static Color get textPrimary => AppTheme.current.textPrimary;
  static Color get textSecondary => AppTheme.current.textSecondary;
  static Color get textLight => AppTheme.current.textLight;
  static Color get textInverse => AppTheme.current.textInverse;
}
