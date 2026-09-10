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
import 'package:careerpilot_ai/shared/widgets/score_ring.dart';
import 'package:careerpilot_ai/shared/widgets/skill_chip.dart';
import 'package:careerpilot_ai/core/services/ad_service.dart';
import 'package:careerpilot_ai/core/widgets/banner_ad_widget.dart';

class AtsResultScreen extends StatefulWidget {
  final Map<String, dynamic>? analysisData;

  const AtsResultScreen({super.key, this.analysisData});

  @override
  State<AtsResultScreen> createState() => _AtsResultScreenState();
}

class _AtsResultScreenState extends State<AtsResultScreen> {
  @override
  void initState() {
    super.initState();
    // Show full-screen interstitial ad upon viewing ATS analysis result
    Future.microtask(() {
      AdService.instance.showInterstitialAd();
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.analysisData ?? {};

    final atsScore = (data['ats_score'] ?? data['total_score'] ?? 85) as int;
    final skillsScore = (data['skills_score'] ?? data['skill_score'] ?? 80) as int;
    final experienceScore = (data['experience_score'] ?? 80) as int;
    final formatScore = (data['format_score'] ?? data['formatting_score'] ?? 90) as int;

    final suitabilityVerdict = (data['suitability_verdict'] as String?) ??
        (atsScore >= 80 ? 'Highly Suitable' : (atsScore >= 60 ? 'Partially Suitable' : 'Needs Skill Improvement'));

    final suitabilitySummary = (data['suitability_summary'] as String?) ??
        (atsScore >= 80
            ? 'Candidate is a strong technical fit for this role. Key qualifications and experience closely match the core job requirements.'
            : (atsScore >= 60
                ? 'Candidate meets foundational requirements but has important skill gaps that should be addressed before applying.'
                : 'Candidate currently has significant skill gaps relative to the job requirements. Targeted skill acquisition is recommended.'));

    final strengths = List<String>.from(
      data['strengths'] ??
          ['Strong technical alignment with job requirements', 'Clear achievement metrics highlighted in experience'],
    );
    final weaknesses = List<String>.from(
      data['weaknesses'] ??
          ['Missing explicit keywords for cloud infrastructure & CI/CD', 'Needs more quantitative business impact metrics'],
    );
    final suggestions = List<String>.from(
      data['improvement_suggestions'] ??
          ['Incorporate missing technical keywords into your work bullet points', 'Quantify your accomplishments with %, \$, or time saved metrics'],
    );
    final matchedSkills = List<String>.from(
      data['matched_skills'] ?? data['matched_keywords'] ?? ['Product Architecture', 'Flutter / Dart', 'Agile Engineering'],
    );
    final missingSkills = List<String>.from(
      data['missing_skills'] ?? data['missing_keywords'] ?? ['Cloud Architecture', 'CI/CD Automation', 'Microservices'],
    );

    final overallColor = atsScore >= 80
        ? AppColors.success
        : (atsScore >= 60 ? AppColors.warning : AppColors.error);

    return AppScaffold(
      bottomNavigationBar: const BannerAdWidget(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: 48,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    AdService.instance.showInterstitialAd(
                      onAdDismissed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/home');
                        }
                      },
                    );
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
                Text('ATS Analysis Report', style: AppTextStyles.h3),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Hero Score Ring Card
            Center(
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                child: Column(
                  children: [
                    ScoreRing(
                      score: atsScore / 100,
                      size: 140,
                      strokeWidth: 10,
                      color: overallColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ATS Match Score',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.08),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Sub-scores Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  _buildSubScoreRing('Skills Match', skillsScore / 100, AppColors.primary),
                  const SizedBox(width: AppSpacing.md),
                  _buildSubScoreRing('Experience Fit', experienceScore / 100, AppColors.softTerracotta),
                  const SizedBox(width: AppSpacing.md),
                  _buildSubScoreRing('Formatting', formatScore / 100, AppColors.success),
                ],
              ),
            ).animate().fadeIn(delay: 150.ms).slideX(begin: 0.08),

            const SizedBox(height: AppSpacing.xl),

            // Candidate Suitability Assessment Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: overallColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Icon(
                          atsScore >= 80
                              ? LucideIcons.userCheck
                              : (atsScore >= 60 ? LucideIcons.alertTriangle : LucideIcons.userX),
                          color: overallColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Candidate Role Suitability', style: AppTextStyles.h4),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: overallColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                suitabilityVerdict,
                                style: AppTextStyles.label.copyWith(
                                  color: overallColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    suitabilitySummary,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.08),

            const SizedBox(height: AppSpacing.md),

            // Skills Needing Improvement & Missing Keywords Section
            _buildCoachingSection(
              title: 'Skills Needing Improvement & Missing Keywords',
              subtitle: 'Crucial qualifications required by employer that are missing from your resume',
              icon: LucideIcons.alertCircle,
              color: AppColors.error,
              items: weaknesses,
              skills: missingSkills
                  .map((s) => SkillChip(label: s, isMatched: false))
                  .toList(),
            ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.08),

            const SizedBox(height: AppSpacing.md),

            // Key Strengths & Matched Qualifications Section
            _buildCoachingSection(
              title: 'Key Strengths & Matched Qualifications',
              subtitle: 'Skills and achievements in your resume that directly align with the target role',
              icon: LucideIcons.checkCircle2,
              color: AppColors.success,
              items: strengths,
              skills: matchedSkills.map((s) => SkillChip(label: s)).toList(),
            ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.08),

            const SizedBox(height: AppSpacing.md),

            // Actionable Suggestions Section
            _buildCoachingSection(
              title: 'Step-by-Step Optimization Plan',
              subtitle: 'Actionable steps to update your resume and boost your ATS match score',
              icon: LucideIcons.sparkles,
              color: AppColors.primary,
              items: suggestions,
              skills: const [],
            ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.08),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSubScoreRing(String title, double value, Color color) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScoreRing(score: value, size: 38, strokeWidth: 4, color: color),
          const SizedBox(width: AppSpacing.sm),
          Text(title, style: AppTextStyles.h4.copyWith(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildCoachingSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<String> items,
    required List<Widget> skills,
  }) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.h4),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (skills.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
