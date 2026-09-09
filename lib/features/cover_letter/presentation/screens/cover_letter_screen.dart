import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/empty_state_card.dart';
import '../../cover_letter/data/cover_letter_repository.dart';
import '../../../core/providers/limits_provider.dart';

class CoverLetterScreen extends ConsumerStatefulWidget {
  const CoverLetterScreen({super.key});

  @override
  ConsumerState<CoverLetterScreen> createState() => _CoverLetterScreenState();
}

class _CoverLetterScreenState extends ConsumerState<CoverLetterScreen> {
  String selectedTone = 'Confident';
  bool isGenerating = false;
  String? generatedLetter;

  Future<void> _generate() async {
    final isPremium = ref.read(isPremiumProvider);
    final limitsAsync = ref.read(usageLimitsProvider);

    if (!isPremium && limitsAsync.value != null) {
      final used = limitsAsync.value!['cover_letters_generated_today'] as int? ?? 0;
      if (used >= 1) {
        context.push('/premium');
        return;
      }
    }

    setState(() => isGenerating = true);
    try {
      final repo = ref.read(coverLetterRepositoryProvider);
      final result = await repo.generateCoverLetter('mock_resume_text', 'mock_job_description', selectedTone);
      setState(() => generatedLetter = result['cover_letter_text']);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(color: AppColors.textInverse, shape: BoxShape.circle),
                    child: const Icon(LucideIcons.arrowLeft, color: AppColors.primary, size: 20),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                const Text('Cover Letter Writer', style: AppTextStyles.h4),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Professional Voice', style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Our AI will draft a compelling narrative connecting your resume to the job description.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  
                  const SizedBox(height: AppSpacing.xl),
                  Text('Select Tone', style: AppTextStyles.labelText),
                  const SizedBox(height: AppSpacing.sm),
                  
                  // Tone Selectors
                  Row(
                    children: [
                      GestureDetector(onTap: () => setState(() => selectedTone = 'Confident'), child: _buildToneChip('Confident', selectedTone == 'Confident')),
                      const SizedBox(width: AppSpacing.sm),
                      GestureDetector(onTap: () => setState(() => selectedTone = 'Humble'), child: _buildToneChip('Humble', selectedTone == 'Humble')),
                      const SizedBox(width: AppSpacing.sm),
                      GestureDetector(onTap: () => setState(() => selectedTone = 'Enthusiastic'), child: _buildToneChip('Enthusiastic', selectedTone == 'Enthusiastic')),
                    ],
                  )
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1),
            
            const SizedBox(height: AppSpacing.xxl),
            
            GradientButton(
              text: 'Generate Draft',
              icon: LucideIcons.penTool,
              isLoading: isGenerating,
              onPressed: _generate,
            ).animate().fadeIn(delay: 200.ms).scale(),
            
            const SizedBox(height: AppSpacing.xxl),
            
            // Output Area
            if (generatedLetter != null)
              GlassCard(
                child: SelectableText(
                  generatedLetter!,
                  style: AppTextStyles.bodyMedium,
                ),
              ).animate().fadeIn()
            else
              const EmptyStateCard(
                title: 'No Draft Yet',
                description: 'Your draft will appear here after generation.',
                icon: LucideIcons.fileText,
              ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildToneChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.secondary : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? AppColors.secondary : AppColors.textLight.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: isSelected ? AppColors.textInverse : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}
