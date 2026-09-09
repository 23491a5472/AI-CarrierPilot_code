import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/score_ring.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/premium_bottom_nav.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../../shared/widgets/error_state_card.dart';
import '../../../shared/widgets/empty_state_card.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final user = ref.watch(currentUserProvider);

    return AppScaffold(
      bottomNavigationBar: const PremiumBottomNav(currentIndex: 0),
      body: profileAsync.when(
        loading: () => const LoadingState(message: 'Syncing your profile...'),
        error: (err, stack) => Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Center(
            child: ErrorStateCard(
              title: 'Sync Failed',
              message: 'Could not load your career profile.',
              onRetry: () => ref.invalidate(profileProvider),
            ),
          ),
        ),
        data: (profile) {
          final fullName = profile?['full_name'] ?? user?.email?.split('@')[0] ?? 'User';
          final careerHealth = profile?['career_health_snapshots'] as List<dynamic>? ?? [];
          final currentScore = careerHealth.isNotEmpty ? (careerHealth.last['ats_score'] as num).toDouble() / 100 : 0.0;
          final scoreLabel = currentScore >= 0.8 ? 'Top 15%' : 'Needs Work';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Welcome back,', style: AppTextStyles.bodySmall),
                        const SizedBox(height: AppSpacing.xs),
                        Text(fullName, style: AppTextStyles.h2),
                      ],
                    ).animate().fadeIn().slideX(begin: -0.1),
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        gradient: AppGradients.heroGradient,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.iconFloating,
                      ),
                      child: const Icon(LucideIcons.user, color: AppColors.textInverse, size: 28),
                    ).animate().scale(),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Hero Glass Card
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Career Health', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                            decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                            child: Text(scoreLabel, style: AppTextStyles.tag.copyWith(color: AppColors.success)),
                          )
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          ScoreRing(score: currentScore == 0 ? 0.01 : currentScore), // Fallback if 0
                          const SizedBox(width: AppSpacing.xl),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildStatusItem('Resume', currentScore >= 0.8 ? 'Excellent' : currentScore == 0.0 ? 'Pending' : 'Average', AppColors.success),
                                const SizedBox(height: AppSpacing.md),
                                _buildStatusItem('Skills', 'Growing', AppColors.accent),
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                
                const SizedBox(height: AppSpacing.xxl),

                // Analytics Chart
                const SectionHeader(title: 'Growth Analytics'),
                const SizedBox(height: AppSpacing.lg),
                GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  blur: 10,
                  child: SizedBox(
                    height: 200,
                    child: careerHealth.length > 1
                        ? LineChart(
                            LineChartData(
                              gridData: FlGridData(show: false),
                              titlesData: FlTitlesData(
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true, reservedSize: 30,
                                    getTitlesWidget: (value, meta) {
                                      if (value.toInt() >= 0 && value.toInt() < careerHealth.length) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 12),
                                          child: Text('Scan ${value.toInt() + 1}', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                                        );
                                      }
                                      return const SizedBox();
                                    },
                                  ),
                                ),
                                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              minY: 0, maxY: 100,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: careerHealth.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['ats_score'] as num).toDouble())).toList(),
                                  isCurved: true, color: AppColors.accent, barWidth: 5, isStrokeCapRound: true,
                                  dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 6, color: AppColors.textInverse, strokeWidth: 3, strokeColor: AppColors.accent)),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(colors: [AppColors.accent.withOpacity(0.3), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const EmptyStateCard(
                            title: 'No Data Yet',
                            description: 'Analyze more resumes to see your growth analytics.',
                            icon: LucideIcons.trendingUp,
                          ),
                  ),
                ).animate().fadeIn(delay: 400.ms).scale(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: AppSpacing.sm),
            Text(value, style: AppTextStyles.h4),
          ],
        )
      ],
    );
  }
}
