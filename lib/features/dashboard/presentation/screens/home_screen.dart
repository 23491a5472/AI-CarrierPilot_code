import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:careerpilot_ai/core/theme/app_colors.dart';
import 'package:careerpilot_ai/core/theme/app_radius.dart';
import 'package:careerpilot_ai/core/theme/app_spacing.dart';
import 'package:careerpilot_ai/core/theme/app_text_styles.dart';
import 'package:careerpilot_ai/core/theme/app_gradients.dart';
import 'package:careerpilot_ai/shared/widgets/app_scaffold.dart';
import 'package:careerpilot_ai/shared/widgets/glass_card.dart';
import 'package:careerpilot_ai/shared/widgets/score_ring.dart';
import 'package:careerpilot_ai/shared/widgets/section_header.dart';
import 'package:careerpilot_ai/shared/widgets/premium_bottom_nav.dart';
import 'package:careerpilot_ai/shared/widgets/loading_state.dart';
import 'package:careerpilot_ai/shared/widgets/error_state_card.dart';
import 'package:careerpilot_ai/shared/widgets/action_card.dart';
import 'package:careerpilot_ai/shared/widgets/ai_insight_card.dart';
import 'package:careerpilot_ai/core/providers/profile_provider.dart';
import 'package:careerpilot_ai/core/providers/auth_provider.dart';
import 'package:careerpilot_ai/core/services/ad_service.dart';
import 'package:careerpilot_ai/core/widgets/banner_ad_widget.dart';
import 'package:careerpilot_ai/features/job_tracker/presentation/screens/job_tracker_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final user = ref.watch(currentUserProvider);
    final appsAsync = ref.watch(applicationsProvider);

    return AppScaffold(
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          BannerAdWidget(),
          PremiumBottomNav(currentIndex: 0),
        ],
      ),
      body: profileAsync.when(
        loading: () => const LoadingState(message: 'Syncing your career profile...'),
        error: (err, stack) => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ErrorStateCard(
              title: 'Sync Failed',
              message: 'Could not load your career profile.',
              onRetry: () => ref.invalidate(profileProvider),
            ),
          ),
        ),
        data: (profile) {
          final fullName =
              profile?['full_name'] ?? user?.email?.split('@')[0] ?? 'Career Professional';
          final careerHealth =
              profile?['career_health_snapshots'] as List<dynamic>? ?? [];
          final currentScore = careerHealth.isNotEmpty
              ? (careerHealth.last['ats_score'] as num).toDouble() / 100
              : 0.0;
          final scoreLabel = currentScore >= 0.8
              ? 'Strong Match'
              : (currentScore > 0 ? 'Needs Optimization' : 'Not Assessed');

          // Analytics aggregations
          double highestScore = 0.0;
          double firstScore = 0.0;
          double scoreGrowth = 0.0;
          if (careerHealth.isNotEmpty) {
            firstScore = (careerHealth.first['ats_score'] as num).toDouble();
            final latestScore = (careerHealth.last['ats_score'] as num).toDouble();
            scoreGrowth = latestScore - firstScore;
            for (final item in careerHealth) {
              final score = (item['ats_score'] as num).toDouble();
              if (score > highestScore) highestScore = score;
            }
          }

          final applications = appsAsync.asData?.value ?? [];
          final totalApps = applications.length;
          final interviewCount = applications
              .where((a) =>
                  a['status'].toString().toLowerCase().contains('interview') ||
                  a['status'].toString().toLowerCase().contains('shortlist'))
              .length;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row with Editorial Greeting
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WELCOME BACK,',
                          style: AppTextStyles.overline.copyWith(
                            color: AppColors.textMuted,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          fullName,
                          style: AppTextStyles.h1,
                        ),
                      ],
                    ).animate().fadeIn().slideX(begin: -0.1),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppGradients.heroGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        LucideIcons.user,
                        color: Colors.white,
                        size: 22,
                      ),
                    ).animate().scale(),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // Hero Deep Walnut & Terracotta Career Health Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  decoration: BoxDecoration(
                    gradient: AppGradients.walnutHero,
                    borderRadius: BorderRadius.circular(AppRadius.xxl),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deepWalnut.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Career Readiness Standing',
                            style: AppTextStyles.h4.copyWith(color: Colors.white),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(AppRadius.chip),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1),
                            ),
                            child: Text(
                              scoreLabel,
                              style: AppTextStyles.overline.copyWith(
                                color: AppColors.softTerracotta,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          ScoreRing(
                            score: currentScore == 0 ? 0.01 : currentScore,
                            size: 104,
                            strokeWidth: 10,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeroStatusItem(
                                  'ATS Match Standing',
                                  currentScore >= 0.8
                                      ? 'Top 15% Candidate'
                                      : (currentScore == 0.0 ? 'Upload Resume First' : 'Optimization Mode'),
                                  AppColors.primary,
                                ),
                                const SizedBox(height: 12),
                                _buildHeroStatusItem(
                                  'Career Strategy Status',
                                  'Active AI Copilot',
                                  AppColors.success,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.08),

                const SizedBox(height: AppSpacing.xl),

                // Signature AI Insight Section
                AiInsightCard(
                  title: currentScore >= 0.8
                      ? 'Strong Resume Keywords Detected'
                      : 'Recommended Action for Next Application',
                  bodyText: currentScore >= 0.8
                      ? 'Your resume shows high keyword density for senior technical roles. Launch Mock Interview Prep to practice targeted questions.'
                      : 'Run a new ATS Resume Scan targeted to your next application to boost match score and generate tailored cover letters.',
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: AppSpacing.lg),

                // Rewarded Ad CTA Banner
                InkWell(
                  onTap: () {
                    AdService.instance.showRewardedAd(
                      onUserEarnedReward: (reward) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('🎉 Reward Unlocked! +1 Bonus AI Resume Scan added.'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.15),
                          AppColors.secondary.withValues(alpha: 0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.gift,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Watch Ad & Unlock Bonus Credit',
                                style: AppTextStyles.h4.copyWith(fontSize: 14),
                              ),
                              Text(
                                'Watch a quick video ad to get 1 free AI Resume Scan.',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          LucideIcons.playCircle,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 220.ms),

                const SizedBox(height: AppSpacing.xl),

                // Quick Tools Header & Grid
                const SectionHeader(
                  title: 'Quick AI Launchpad',
                  subtitle: 'Accelerate your job search workflow',
                ),
                const SizedBox(height: AppSpacing.md),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.25,
                  children: [
                    ActionCard(
                      title: 'Analyze Resume',
                      subtitle: 'ATS score & feedback',
                      icon: LucideIcons.scanLine,
                      onTap: () => context.go('/analyze'),
                    ),
                    ActionCard(
                      title: 'Cover Letter',
                      subtitle: 'Generate in seconds',
                      icon: LucideIcons.penTool,
                      onTap: () => context.go('/cover-letter'),
                    ),
                    ActionCard(
                      title: 'Interview Prep',
                      subtitle: 'Tailored Q&A practice',
                      icon: LucideIcons.messageSquare,
                      onTap: () => context.go('/interview-prep'),
                    ),
                    ActionCard(
                      title: 'Job Tracker',
                      subtitle: 'Manage applications',
                      icon: LucideIcons.briefcase,
                      onTap: () => context.go('/jobs'),
                    ),
                  ],
                ).animate().fadeIn(delay: 250.ms),

                const SizedBox(height: AppSpacing.xl),

                // Growth Analytics Section
                const SectionHeader(
                  title: 'Growth Analytics',
                  subtitle: 'Score progression & job search telemetry',
                ),
                const SizedBox(height: AppSpacing.md),

                // Metric Cards Row
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricBadge(
                        title: 'Peak ATS',
                        value: highestScore > 0 ? '${highestScore.toInt()}%' : 'N/A',
                        subtitle: careerHealth.length > 1
                            ? '${scoreGrowth >= 0 ? '+' : ''}${scoreGrowth.toInt()}% delta'
                            : '1st scan',
                        icon: LucideIcons.trophy,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricBadge(
                        title: 'Tracked Jobs',
                        value: '$totalApps',
                        subtitle: '$interviewCount active',
                        icon: LucideIcons.briefcase,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricBadge(
                        title: 'Scans Run',
                        value: '${careerHealth.length}',
                        subtitle: 'Resume history',
                        icon: LucideIcons.fileText,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: AppSpacing.md),

                // Growth Line Chart Card
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ATS Score Trend', style: AppTextStyles.h4),
                          if (careerHealth.length > 1)
                            Text(
                              '${careerHealth.length} Scans Evaluated',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        height: 180,
                        child: careerHealth.length > 1
                            ? LineChart(
                                LineChartData(
                                  gridData: const FlGridData(show: false),
                                  titlesData: FlTitlesData(
                                    rightTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false)),
                                    topTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 28,
                                        getTitlesWidget: (value, meta) {
                                          if (value.toInt() >= 0 &&
                                              value.toInt() < careerHealth.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Text(
                                                'Scan ${value.toInt() + 1}',
                                                style: AppTextStyles.bodySmall,
                                              ),
                                            );
                                          }
                                          return const SizedBox();
                                        },
                                      ),
                                    ),
                                    leftTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  minY: 0,
                                  maxY: 100,
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: careerHealth
                                          .asMap()
                                          .entries
                                          .map((e) => FlSpot(
                                                e.key.toDouble(),
                                                (e.value['ats_score'] as num)
                                                    .toDouble(),
                                              ))
                                          .toList(),
                                      isCurved: true,
                                      color: AppColors.primary,
                                      barWidth: 3,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(
                                        show: true,
                                        getDotPainter:
                                            (spot, percent, barData, index) =>
                                                FlDotCirclePainter(
                                          radius: 4,
                                          color: AppColors.surface,
                                          strokeWidth: 2,
                                          strokeColor: AppColors.primary,
                                        ),
                                      ),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: AppColors.primary
                                            .withValues(alpha: 0.1),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppColors.softTerracotta.withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          LucideIcons.trendingUp,
                                          size: 24,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'No Progression Analytics Yet',
                                        style: AppTextStyles.h4.copyWith(fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Run multiple resume scans to visualize your score progression over time.',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textMuted,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 350.ms),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroStatusItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                value,
                style: AppTextStyles.h4.copyWith(fontSize: 14, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricBadge({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTextStyles.overline.copyWith(
              color: AppColors.textMuted,
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
