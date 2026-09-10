import 'package:flutter/material.dart';
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
import 'package:careerpilot_ai/shared/widgets/secondary_button.dart';

class AiPersonaScreen extends ConsumerStatefulWidget {
  const AiPersonaScreen({super.key});

  @override
  ConsumerState<AiPersonaScreen> createState() => _AiPersonaScreenState();
}

class _AiPersonaScreenState extends ConsumerState<AiPersonaScreen> {
  String selectedAiPersona = 'Strict ATS Recruiter';

  final List<Map<String, String>> personas = [
    {
      'title': 'Strict ATS Recruiter',
      'subtitle': 'Direct, high-standard filtering matching enterprise hiring committee criteria.',
      'icon': 'shieldAlert',
    },
    {
      'title': 'Encouraging Career Mentor',
      'subtitle': 'Supportive, encouraging guidance emphasizing strengths & step-by-step career growth.',
      'icon': 'heartHandshake',
    },
    {
      'title': 'Executive Hiring Manager',
      'subtitle': 'Strategic, leadership-focused evaluation prioritizing business ROI and metrics.',
      'icon': 'briefcase',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                      Text('AI Coaching Persona', style: AppTextStyles.h3),
                      Text(
                        'Configure AI feedback tone & scoring rigor',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Feedback Persona', style: AppTextStyles.labelText),
                  const SizedBox(height: 12),
                  Column(
                    children: personas.map((p) {
                      final title = p['title']!;
                      final subtitle = p['subtitle']!;
                      final isSelected = selectedAiPersona == title;

                      return InkWell(
                        onTap: () => setState(() => selectedAiPersona = title),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.08)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? LucideIcons.checkCircle2
                                    : LucideIcons.circle,
                                size: 20,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight:
                                            isSelected ? FontWeight.w600 : FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      subtitle,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SecondaryButton(
                    text: 'Save Persona Preference',
                    icon: LucideIcons.save,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('AI Persona set to "$selectedAiPersona"')),
                      );
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/profile');
                      }
                    },
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.08),
          ],
        ),
      ),
    );
  }
}
