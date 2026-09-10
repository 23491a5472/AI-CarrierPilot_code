import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:careerpilot_ai/core/theme/app_colors.dart';
import 'package:careerpilot_ai/core/theme/app_radius.dart';
import 'package:careerpilot_ai/core/theme/app_text_styles.dart';
import 'package:careerpilot_ai/core/theme/app_spacing.dart';
import 'package:careerpilot_ai/shared/widgets/app_scaffold.dart';
import 'package:careerpilot_ai/shared/widgets/glass_card.dart';
import 'package:careerpilot_ai/shared/widgets/gradient_button.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(LucideIcons.x, color: AppColors.textPrimary),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                LucideIcons.crown,
                size: 36,
                color: Colors.white,
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.easeOutCubic),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'CareerPilot Pro',
              textAlign: TextAlign.center,
              style: AppTextStyles.h1,
            ),
            const SizedBox(height: 4),
            Text(
              'Unlimited access to AI resume scans, cover letters, and interview coaching.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Features Card
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Column(
                children: [
                  _buildFeature(LucideIcons.infinity, 'Unlimited ATS Resume Scans'),
                  _buildFeature(LucideIcons.penTool, 'Unlimited Tailored Cover Letters'),
                  _buildFeature(LucideIcons.mic, 'Unlimited Mock Interview Practice'),
                  _buildFeature(LucideIcons.zap, 'Detailed Skill Gap Analytics'),
                ],
              ),
            ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.08),

            const SizedBox(height: AppSpacing.lg),

            // Pricing Plan Card
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pro Annual Plan', style: AppTextStyles.h4),
                      Text(
                        '\$9.99 / month',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.softTerracotta.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                    child: Text(
                      'SAVE 40%',
                      style: AppTextStyles.overline.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 250.ms).slideX(begin: 0.08),

            const SizedBox(height: AppSpacing.xl),

            GradientButton(
              text: 'Start 7-Day Free Trial',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Free trial initiated')),
                );
              },
            ).animate().fadeIn(delay: 350.ms).scale(),

            const SizedBox(height: AppSpacing.md),
            Text(
              'Cancel anytime. Billed annually after trial.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.softTerracotta.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
