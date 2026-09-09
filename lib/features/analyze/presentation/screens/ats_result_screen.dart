import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/score_ring.dart';
import '../../../shared/widgets/skill_chip.dart';

class AtsResultScreen extends StatelessWidget {
  final Map<String, dynamic>? analysisData;

  const AtsResultScreen({super.key, this.analysisData});

  @override
  Widget build(BuildContext context) {
    // If we have actual data, use it. Otherwise, use mock data for design consistency.
    final atsScore = analysisData?['ats_score'] as int? ?? 88;
    final skillsScore = analysisData?['skills_score'] as int? ?? 90;
    final experienceScore = analysisData?['experience_score'] as int? ?? 80;
    final formatScore = analysisData?['format_score'] as int? ?? 95;
    
    final strengths = List<String>.from(analysisData?['strengths'] ?? ['Strong product management background', 'Clear metric-driven achievements']);
    final weaknesses = List<String>.from(analysisData?['weaknesses'] ?? ['Missing "Cloud Computing" keywords', 'Need more emphasis on "Team Leadership"']);
    final matchedSkills = List<String>.from(analysisData?['matched_skills'] ?? ['Product Management', 'Agile']);
    final missingSkills = List<String>.from(analysisData?['missing_skills'] ?? ['Cloud Computing', 'Team Leadership']);

    final overallLabel = atsScore >= 80 ? 'Excellent' : (atsScore >= 60 ? 'Good' : 'Needs Work');
    final overallColor = atsScore >= 80 ? AppColors.success : (atsScore >= 60 ? AppColors.accent : AppColors.warning);

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
                    decoration: BoxDecoration(color: AppColors.textInverse, shape: BoxShape.circle, boxShadow: AppShadows.softCard),
                    child: const Icon(LucideIcons.arrowLeft, color: AppColors.primary, size: 20),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                const Text('Analysis Insights', style: AppTextStyles.h4),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            // Hero Score Glass Card
            Center(
              child: GlassCard(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                borderRadius: BorderRadius.circular(40),
                child: ScoreRing(score: atsScore / 100, size: 160, label: overallLabel, color: overallColor),
              ).animate().fadeIn().slideY(begin: 0.1),
            ),
            
            const SizedBox(height: AppSpacing.xxl),
            
            // Glass Sub-scores Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  _buildSubScoreRing('Skills', skillsScore / 100, AppColors.secondary),
                  const SizedBox(width: AppSpacing.md),
                  _buildSubScoreRing('Experience', experienceScore / 100, AppColors.accent),
                  const SizedBox(width: AppSpacing.md),
                  _buildSubScoreRing('Format', formatScore / 100, AppColors.success),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),

            const SizedBox(height: AppSpacing.xxl),
            
            // Rich Coaching Content Sections
            _buildCoachingSection(
              title: 'Your Strengths', icon: LucideIcons.checkCircle2, color: AppColors.success,
              items: strengths,
              skills: matchedSkills.map((s) => SkillChip(label: s)).toList(),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
            
            const SizedBox(height: AppSpacing.lg),
            
            _buildCoachingSection(
              title: 'Areas for Growth', icon: LucideIcons.target, color: AppColors.secondary,
              items: weaknesses,
              skills: missingSkills.map((s) => SkillChip(label: s, isMatched: false)).toList(),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildSubScoreRing(String title, double value, Color color) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
      child: Row(
        children: [
          ScoreRing(score: value, size: 40, strokeWidth: 6, color: color),
          const SizedBox(width: AppSpacing.md),
          Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildCoachingSection({required String title, required IconData icon, required Color color, required List<String> items, required List<Widget> skills}) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(title, style: AppTextStyles.h4),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: skills,
          ),
          const SizedBox(height: AppSpacing.lg),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(margin: const EdgeInsets.only(top: 8), width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(item, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
