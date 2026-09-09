import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import 'glass_card.dart';

class NativeAdCard extends StatelessWidget {
  const NativeAdCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: AppColors.bgSecondary, borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.ad_units, color: AppColors.textLight),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                  child: Text('AD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.accent)),
                ),
                const SizedBox(height: 4),
                Text('Upgrade to Premium', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                Text('Get unlimited resume scans.', style: AppTextStyles.bodySmall),
              ],
            ),
          )
        ],
      ),
    );
  }
}
