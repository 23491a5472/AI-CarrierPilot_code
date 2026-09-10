import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/skill_chip.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/empty_state_card.dart';
import '../../data/skill_gap_repository.dart';

class SkillGapScreen extends ConsumerStatefulWidget {
  const SkillGapScreen({super.key});

  @override
  ConsumerState<SkillGapScreen> createState() => _SkillGapScreenState();
}

class _SkillGapScreenState extends ConsumerState<SkillGapScreen> {
  bool isGenerating = false;
  Map<String, dynamic>? report;

  Future<void> _generateReport() async {
    setState(() => isGenerating = true);
    try {
      final repo = ref.read(skillGapRepositoryProvider);
      final result = await repo.generateSkillGapReport('mock_resume', 'mock_job');
      setState(() => report = result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
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
                Text('Skill Gap Analysis', style: AppTextStyles.h3),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            if (report == null) ...[
              EmptyStateCard(
                title: 'Identify Career Gaps',
                description:
                    'Analyze your current experience against target job roles to highlight missing skills and courses.',
                icon: LucideIcons.target,
                action: GradientButton(
                  text: 'Generate Skill Gap Report',
                  icon: LucideIcons.sparkles,
                  onPressed: _generateReport,
                  isLoading: isGenerating,
                ),
              ).animate().fadeIn().slideY(begin: 0.08),
            ] else ...[
              // Missing skills card
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Missing Target Skills', style: AppTextStyles.h3),
                    const SizedBox(height: 4),
                    Text(
                      'Acquiring these key skills can boost your ATS match score significantly.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (report!['missing_skills'] as List<dynamic>)
                          .map((skill) => SkillChip(
                                label: skill.toString(),
                                isMatched: false,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.08),

              const SizedBox(height: AppSpacing.xl),

              const SectionHeader(
                title: 'Recommended Upskilling',
                subtitle: 'Top courses to close identified gaps',
              ),
              const SizedBox(height: AppSpacing.md),

              ...((report!['course_recommendations'] as List<dynamic>? ?? []).map((course) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _buildCourseCard(
                    course['title'] ?? 'Course Title',
                    course['platform'] ?? 'Coursera / Udemy',
                    LucideIcons.video,
                  ).animate().fadeIn(),
                );
              }).toList()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(String title, String subtitle, IconData icon) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.softTerracotta.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h4.copyWith(fontSize: 15),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Icon(LucideIcons.chevronRight, color: AppColors.textMuted, size: 18),
        ],
      ),
    );
  }
}
