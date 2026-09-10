import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:careerpilot_ai/core/theme/app_colors.dart';
import 'package:careerpilot_ai/core/theme/app_text_styles.dart';
import 'package:careerpilot_ai/core/theme/app_spacing.dart';
import 'package:careerpilot_ai/shared/widgets/app_scaffold.dart';
import 'package:careerpilot_ai/shared/widgets/glass_card.dart';
import 'package:careerpilot_ai/shared/widgets/gradient_button.dart';
import 'package:careerpilot_ai/core/providers/limits_provider.dart';

class UsageTelemetryScreen extends ConsumerWidget {
  const UsageTelemetryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);
    final limitsAsync = ref.watch(usageLimitsProvider);

    final limits = limitsAsync.asData?.value;
    final atsUsed = limits?['ats_scans_used_today'] ?? 0;
    final coverLettersUsed = limits?['cover_letters_used_today'] ?? 0;

    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Row with Back Button
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/profile');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Icon(
                      LucideIcons.arrowLeft,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily AI Usage Telemetry', style: AppTextStyles.h3),
                      Text(
                        'Monitor daily feature scan and generation quotas',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            AppCard(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Column(
                children: [
                  _buildQuotaRow(
                    icon: LucideIcons.scanLine,
                    title: 'ATS Resume Scans',
                    used: isPremium ? 'Unlimited' : '$atsUsed / 3 today',
                    progress: isPremium ? 1.0 : (atsUsed / 3).clamp(0.0, 1.0),
                  ),
                  const SizedBox(height: 18),
                  _buildQuotaRow(
                    icon: LucideIcons.penTool,
                    title: 'Cover Letter Generators',
                    used: isPremium ? 'Unlimited' : '$coverLettersUsed / 3 today',
                    progress: isPremium ? 1.0 : (coverLettersUsed / 3).clamp(0.0, 1.0),
                  ),
                  const SizedBox(height: 18),
                  _buildQuotaRow(
                    icon: LucideIcons.messageSquare,
                    title: 'Mock Interview Question Practice',
                    used: isPremium ? 'Unlimited' : '1 Free Set',
                    progress: 1.0,
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.08),

            const SizedBox(height: AppSpacing.xl),

            if (!isPremium) ...[
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                child: Column(
                  children: [
                    Icon(LucideIcons.crown, size: 36, color: AppColors.primary),
                    const SizedBox(height: 10),
                    Text('Unlock Unlimited Quotas', style: AppTextStyles.h3),
                    const SizedBox(height: 6),
                    Text(
                      'Upgrade to Pro for unlimited ATS analyses, instant cover letter generations, and unlimited AI mock interview question batches.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    GradientButton(
                      text: 'Upgrade to Unlimited Pro',
                      icon: LucideIcons.crown,
                      onPressed: () => context.push('/premium'),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 150.ms),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuotaRow({
    required IconData icon,
    required String title,
    required String used,
    required double progress,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            Text(
              used,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.border.withValues(alpha: 0.5),
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
