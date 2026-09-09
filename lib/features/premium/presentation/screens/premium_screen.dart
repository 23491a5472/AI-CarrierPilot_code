import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_button.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(LucideIcons.x, color: AppColors.textPrimary),
                onPressed: () => context.pop(),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(gradient: AppGradients.amberGradient, shape: BoxShape.circle),
              child: const Icon(LucideIcons.crown, size: 40, color: AppColors.textInverse),
            ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
            const SizedBox(height: AppSpacing.lg),
            const Text('Unlock Your Career\nPotential', textAlign: TextAlign.center, style: AppTextStyles.h1),
            const SizedBox(height: AppSpacing.sm),
            Text('Get unlimited access to AI coaching, resume tailoring, and interview prep.', textAlign: TextAlign.center, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            
            const SizedBox(height: AppSpacing.xxl),
            
            // Features Glass Card
            GlassCard(
              child: Column(
                children: [
                  _buildFeature(LucideIcons.infinity, 'Unlimited Resume ATS Scans'),
                  _buildFeature(LucideIcons.penTool, 'Unlimited AI Cover Letters'),
                  _buildFeature(LucideIcons.mic, 'Unlimited Mock Interviews'),
                  _buildFeature(LucideIcons.zap, 'Advanced Skill Gap Reports'),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
            
            const SizedBox(height: AppSpacing.xxl),
            
            // Pricing Plan
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pro Annual', style: AppTextStyles.h4),
                      Text('\$9.99 / month', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text('SAVE 40%', style: AppTextStyles.tag.copyWith(color: AppColors.accent)),
                  )
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),
            
            const SizedBox(height: AppSpacing.xxl),
            
            GradientButton(
              text: 'Start 7-Day Free Trial',
              gradient: AppGradients.heroGradient,
              onPressed: () {},
            ).animate().fadeIn(delay: 600.ms).scale(),
            
            const SizedBox(height: AppSpacing.md),
            Text('Cancel anytime. Billed annually at \$119.88 after trial.', style: AppTextStyles.caption, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
