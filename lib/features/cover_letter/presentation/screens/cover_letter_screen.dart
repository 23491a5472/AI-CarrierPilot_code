import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:careerpilot_ai/core/theme/app_colors.dart';
import 'package:careerpilot_ai/core/theme/app_radius.dart';
import 'package:careerpilot_ai/core/theme/app_text_styles.dart';
import 'package:careerpilot_ai/core/theme/app_spacing.dart';
import 'package:careerpilot_ai/shared/widgets/app_scaffold.dart';
import 'package:careerpilot_ai/shared/widgets/glass_card.dart';
import 'package:careerpilot_ai/shared/widgets/gradient_button.dart';
import 'package:careerpilot_ai/shared/widgets/empty_state_card.dart';
import 'package:careerpilot_ai/features/cover_letter/data/cover_letter_repository.dart';
import 'package:careerpilot_ai/core/providers/limits_provider.dart';

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
      final used = limitsAsync.value!['cover_letters_used_today'] as int? ?? 0;
      if (used >= 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Daily free Cover Letter limit (1/1) reached. Upgrade to Pro for unlimited generation.'),
          ),
        );
        context.push('/premium');
        return;
      }
    }

    setState(() => isGenerating = true);
    try {
      final repo = ref.read(coverLetterRepositoryProvider);
      final result = await repo.generateCoverLetter(
        'Senior Software / Product Engineer resume content',
        'Senior Lead Engineer requirements',
        selectedTone,
      );
      setState(() => generatedLetter = result['cover_letter_text']);

      ref.invalidate(usageLimitsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception:', '').trim()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
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
                Text('Cover Letter Writer', style: AppTextStyles.h3),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            AppCard(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Narrative Tone', style: AppTextStyles.h3),
                  const SizedBox(height: 4),
                  Text(
                    'AI will craft a tailored letter bridging your experience to the role.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Select Tone', style: AppTextStyles.labelText),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildToneChip('Confident'),
                      _buildToneChip('Humble'),
                      _buildToneChip('Enthusiastic'),
                      _buildToneChip('Executive'),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.08),

            const SizedBox(height: AppSpacing.lg),

            GradientButton(
              text: 'Generate Cover Letter',
              icon: LucideIcons.penTool,
              isLoading: isGenerating,
              onPressed: _generate,
            ).animate().fadeIn(delay: 150.ms).scale(),

            const SizedBox(height: AppSpacing.xl),

            // Output Area
            if (generatedLetter != null)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Generated Draft', style: AppTextStyles.h4),
                        IconButton(
                          icon: const Icon(LucideIcons.copy, size: 18),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: generatedLetter!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied cover letter to clipboard'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    SelectableText(
                      generatedLetter!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn()
            else
              const EmptyStateCard(
                title: 'No Letter Generated Yet',
                description:
                    'Select a tone above and tap Generate to create your custom cover letter draft.',
                icon: LucideIcons.fileText,
              ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildToneChip(String label) {
    final isSelected = selectedTone == label;
    return GestureDetector(
      onTap: () => setState(() => selectedTone = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
