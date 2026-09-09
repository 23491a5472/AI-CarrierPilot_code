import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  static LinearGradient get heroGradient => LinearGradient(
    colors: [AppColors.secondary, AppColors.mutedCoral],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get amberGradient => LinearGradient(
    colors: [AppColors.accent, AppColors.dustyRose],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get successGradient => LinearGradient(
    colors: [AppColors.success, AppColors.success.withOpacity(0.6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Background blobs
  static RadialGradient blobCoral(double opacity) => RadialGradient(
    colors: [AppColors.mutedCoral.withOpacity(opacity), Colors.transparent],
  );

  static RadialGradient blobAmber(double opacity) => RadialGradient(
    colors: [AppColors.accent.withOpacity(opacity), Colors.transparent],
  );

  static RadialGradient blobSecondary(double opacity) => RadialGradient(
    colors: [AppColors.secondary.withOpacity(opacity), Colors.transparent],
  );
}
