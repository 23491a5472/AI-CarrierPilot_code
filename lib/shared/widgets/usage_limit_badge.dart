import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Clean usage limit badge for Warm Career design system.
class UsageLimitBadge extends StatelessWidget {
  final int used;
  final int limit;
  final VoidCallback onUpgrade;

  const UsageLimitBadge({
    super.key,
    required this.used,
    required this.limit,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final isLimitReached = used >= limit;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isLimitReached ? AppColors.warning : AppColors.softTerracotta,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$used of $limit Scans Used',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          GestureDetector(
            onTap: onUpgrade,
            child: Text(
              'UPGRADE',
              style: AppTextStyles.overline.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
