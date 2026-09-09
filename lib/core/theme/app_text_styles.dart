import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headings
  static TextStyle get h1 => TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: -1, height: 1.1);
  static TextStyle get h2 => TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: -1, height: 1.2);
  static TextStyle get h3 => TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: -0.5, height: 1.2);
  static TextStyle get h4 => TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary, height: 1.3);
  
  // Body
  static TextStyle get bodyLarge => TextStyle(fontSize: 18, color: AppColors.textPrimary, height: 1.5);
  static TextStyle get bodyMedium => TextStyle(fontSize: 16, color: AppColors.textPrimary, height: 1.5);
  static TextStyle get bodySmall => TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5);
  
  // Special
  static TextStyle get buttonText => TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textInverse, letterSpacing: 0.5);
  static TextStyle get labelText => TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary);
  static TextStyle get caption => TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textLight);
  
  // Specific Use Cases
  static TextStyle get scoreLarge => TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: AppColors.primary, height: 1.1);
  static TextStyle get scoreMedium => TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppColors.primary, height: 1);
  static TextStyle get tag => const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1);
}
