import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import 'glass_card.dart';

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
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: AppSpacing.md),
      borderRadius: BorderRadius.circular(30),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
          const SizedBox(width: AppSpacing.sm),
          Text('$used of $limit Scans Used', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
          const SizedBox(width: AppSpacing.md),
          GestureDetector(
            onTap: onUpgrade,
            child: Text('UPGRADE', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }
}
