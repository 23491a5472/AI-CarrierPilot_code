import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  // Soft, layered glass shadows
  static List<BoxShadow> get glass => [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.08),
      blurRadius: 32,
      offset: const Offset(0, 16),
    )
  ];

  static List<BoxShadow> get buttonPrimary => [
    BoxShadow(
      color: AppColors.secondary.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 10),
    )
  ];

  static List<BoxShadow> get iconFloating => [
    BoxShadow(
      color: AppColors.secondary.withOpacity(0.4),
      blurRadius: 30,
      offset: const Offset(0, 15),
    )
  ];

  static List<BoxShadow> get softCard => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    )
  ];
}
