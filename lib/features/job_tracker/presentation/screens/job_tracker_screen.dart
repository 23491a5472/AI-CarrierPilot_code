import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/premium_bottom_nav.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../../shared/widgets/error_state_card.dart';
import '../../../shared/widgets/empty_state_card.dart';
import '../../job_tracker/data/job_tracker_repository.dart';

final applicationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(jobTrackerRepositoryProvider);
  return repo.getApplications();
});

class JobTrackerScreen extends ConsumerWidget {
  const JobTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(applicationsProvider);

    return AppScaffold(
      bottomNavigationBar: const PremiumBottomNav(currentIndex: 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Job Tracker', style: AppTextStyles.h1),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(LucideIcons.plus, color: AppColors.textInverse, size: 24),
                )
              ],
            ).animate().fadeIn().slideX(),
            const SizedBox(height: AppSpacing.xxl),
            
            const Text('Active Applications', style: AppTextStyles.labelText).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: AppSpacing.md),
            
            applicationsAsync.when(
              loading: () => const LoadingState(message: 'Loading your tracker...'),
              error: (err, stack) => ErrorStateCard(
                title: 'Tracker Error',
                message: 'Could not load your saved jobs.',
                onRetry: () => ref.invalidate(applicationsProvider),
              ),
              data: (applications) {
                if (applications.isEmpty) {
                  return const EmptyStateCard(
                    title: 'No Jobs Tracked',
                    description: 'Start analyzing resumes to save job matches here.',
                    icon: LucideIcons.briefcase,
                  ).animate().scale(delay: 200.ms);
                }
                
                return Column(
                  children: applications.map((app) {
                    final title = app['title'] ?? 'Unknown Title';
                    final company = app['company'] ?? 'Unknown Company';
                    final score = app['match_percentage'] ?? 0;
                    final status = score >= 80 ? 'Strong Match' : 'Applied';
                    final color = score >= 80 ? AppColors.success : AppColors.accent;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _buildJobCard(title, company, status, color).animate().fadeIn(),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(String title, String company, String status, Color statusColor) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppColors.bgSecondary, borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Icon(LucideIcons.building, color: AppColors.textLight)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(company, style: AppTextStyles.bodySmall),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor, letterSpacing: 0.5)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
