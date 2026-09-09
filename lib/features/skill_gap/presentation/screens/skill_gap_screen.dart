import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
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
                    child: Icon(LucideIcons.arrowLeft, color: AppColors.primary, size: 20),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text('Skill Gap Analysis', style: AppTextStyles.h4),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            if (report == null) ...[
              EmptyStateCard(
                title: 'Find Your Blind Spots',
                description: 'Our AI will analyze your resume against the job description to find missing key skills.',
                icon: LucideIcons.target,
                action: GradientButton(text: 'Generate Report', onPressed: _generateReport, isLoading: isGenerating),
              ).animate().fadeIn().slideY(begin: 0.1),
            ] else ...[
              // Hero Chart Representation
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Missing Core Skills', style: AppTextStyles.h3),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Focus on these to increase your ATS score by 12%.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: AppSpacing.lg),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: (report!['missing_skills'] as List<dynamic>).map((skill) => SkillChip(label: skill.toString(), isMatched: false)).toList(),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1),
              
              const SizedBox(height: AppSpacing.xxl),
              
              const SectionHeader(title: 'Recommended Courses'),
              const SizedBox(height: AppSpacing.md),
              
              // Recommendation List
              ...((report!['course_recommendations'] as List<dynamic>? ?? []).map((course) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _buildCourseCard(course['title'], course['platform'], LucideIcons.video).animate().fadeIn(),
                );
              }).toList()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(String title, String subtitle, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Icon(LucideIcons.chevronRight, color: AppColors.textLight),
        ],
      ),
    );
  }
}
