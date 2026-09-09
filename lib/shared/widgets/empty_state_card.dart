import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import 'glass_card.dart';

class EmptyStateCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Widget? action;

  const EmptyStateCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.mutedCoral.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: AppColors.secondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(title, style: AppTextStyles.h4, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(description, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.lg),
            action!,
          ]
        ],
      ),
    );
  }
}
