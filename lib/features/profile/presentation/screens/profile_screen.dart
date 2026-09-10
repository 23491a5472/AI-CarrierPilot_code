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
import 'package:careerpilot_ai/shared/widgets/premium_bottom_nav.dart';
import 'package:careerpilot_ai/shared/widgets/section_header.dart';
import 'package:careerpilot_ai/shared/widgets/loading_state.dart';
import 'package:careerpilot_ai/shared/widgets/error_state_card.dart';
import 'package:careerpilot_ai/core/providers/profile_provider.dart';
import 'package:careerpilot_ai/core/providers/auth_provider.dart';
import 'package:careerpilot_ai/core/providers/limits_provider.dart';
import 'package:careerpilot_ai/features/job_tracker/presentation/screens/job_tracker_screen.dart';
import 'package:careerpilot_ai/core/providers/theme_provider.dart';
import 'package:careerpilot_ai/core/widgets/banner_ad_widget.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final user = ref.watch(currentUserProvider);
    final appsAsync = ref.watch(applicationsProvider);

    return AppScaffold(
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          BannerAdWidget(),
          PremiumBottomNav(currentIndex: 3),
        ],
      ),
      body: profileAsync.when(
        loading: () => const LoadingState(message: 'Loading your profile hub...'),
        error: (err, stack) => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ErrorStateCard(
              title: 'Profile Hub Error',
              message: 'Could not load your profile hub.',
              onRetry: () => ref.invalidate(profileProvider),
            ),
          ),
        ),
        data: (profile) {
          final fullName =
              profile?['full_name'] ?? user?.email?.split('@')[0] ?? 'Career Professional';
          final email = user?.email ?? '';
          final initials =
              fullName.isNotEmpty ? fullName.substring(0, 1).toUpperCase() : 'C';

          final careerHealth =
              profile?['career_health_snapshots'] as List<dynamic>? ?? [];
          final applicationsCount = appsAsync.asData?.value.length ?? 0;
          final experienceLevel =
              profile?['experience_level'] as String? ?? 'Senior';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Career Profile',
                  subtitle: 'Manage goals, telemetry, AI persona & account',
                ),
                const SizedBox(height: AppSpacing.lg),

                // User Identity Hero Card
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fullName,
                                  style: AppTextStyles.h3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  email,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (isPremium
                                            ? AppColors.primary
                                            : AppColors.softTerracotta)
                                        .withValues(alpha: 0.12),
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.chip),
                                  ),
                                  child: Text(
                                    isPremium ? 'PRO MEMBER' : 'FREE PLAN',
                                    style: AppTextStyles.overline.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Divider(height: 1),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatBadge('Scans', '${careerHealth.length}'),
                          _buildDivider(),
                          _buildStatBadge('Tracked', '$applicationsCount'),
                          _buildDivider(),
                          _buildStatBadge('Level', experienceLevel),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.08),

                const SizedBox(height: AppSpacing.xl),

                // Settings Menu List 0: Appearance & Theme Mode
                const SectionHeader(
                  title: 'Appearance & Theme Mode',
                  subtitle: 'Switch between Dark Mode and Light Mode',
                ),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(
                            ref.watch(themeProvider).isDarkMode
                                ? LucideIcons.moon
                                : LucideIcons.sun,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ref.watch(themeProvider).isDarkMode
                                    ? 'Technical Slate Dark'
                                    : 'Quartz & Mint Light',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                ref.watch(themeProvider).isDarkMode
                                    ? 'Deep Slate #0F172A & Electric Coral #FF6B6B'
                                    : 'Clean Quartz #F7FAFC & Fresh Mint #4FD1C5',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: ref.watch(themeProvider).isDarkMode,
                          activeTrackColor: AppColors.primary,
                          onChanged: (val) {
                            ref.read(themeProvider.notifier).toggleTheme(val);
                          },
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.08),

                const SizedBox(height: AppSpacing.xl),

                // Settings Menu List 1: Career Goals & Customization
                const SectionHeader(
                  title: 'Career Targets & AI Settings',
                  subtitle: 'Configure role criteria and AI evaluation',
                ),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildMenuItem(
                        context: context,
                        icon: LucideIcons.target,
                        title: 'Career Targets & Goals',
                        subtitle: 'Job title, experience level, work mode & salary',
                        onTap: () => context.push('/profile/career-targets'),
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildMenuItem(
                        context: context,
                        icon: LucideIcons.bot,
                        title: 'AI Coaching Persona',
                        subtitle: 'Strict recruiter vs encouraging mentor',
                        onTap: () => context.push('/profile/ai-persona'),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.08),

                const SizedBox(height: AppSpacing.xl),

                // Settings Menu List 2: Telemetry & Membership
                const SectionHeader(
                  title: 'Usage & Membership',
                  subtitle: 'Daily AI quotas and subscription plan',
                ),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildMenuItem(
                        context: context,
                        icon: LucideIcons.gauge,
                        title: 'Daily AI Usage Telemetry',
                        subtitle: 'Check daily scan and generation quotas',
                        onTap: () => context.push('/profile/usage-telemetry'),
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildMenuItem(
                        context: context,
                        icon: LucideIcons.crown,
                        title: 'Subscription & Membership',
                        subtitle: isPremium ? 'Pro Active Plan' : 'Upgrade for Unlimited AI access',
                        badgeText: isPremium ? 'PRO' : 'UPGRADE',
                        onTap: () => context.push('/premium'),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.08),

                const SizedBox(height: AppSpacing.xl),

                // Settings Menu List 3: Account & Storage
                const SectionHeader(
                  title: 'Account & Vault',
                  subtitle: 'Personal details and stored documents',
                ),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _buildMenuItem(
                        context: context,
                        icon: LucideIcons.user,
                        title: 'Account Settings',
                        subtitle: 'Full name, email address & security',
                        onTap: () => context.push('/profile/account-settings'),
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildMenuItem(
                        context: context,
                        icon: LucideIcons.fileText,
                        title: 'Resume Library Vault',
                        subtitle: 'Manage saved resume uploads & versions',
                        onTap: () => context.push('/resume-library'),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.08),

                const SizedBox(height: AppSpacing.xl),

                // Sign Out & App Info
                Center(
                  child: Column(
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          await ref.read(supabaseClientProvider).auth.signOut();
                          ref.invalidate(profileProvider);
                          ref.invalidate(subscriptionProvider);
                          ref.invalidate(usageLimitsProvider);
                          if (context.mounted) context.go('/login');
                        },
                        icon: Icon(LucideIcons.logOut, size: 18, color: AppColors.error),
                        label: Text(
                          'Sign Out',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'AI CareerPilot v1.2.0 • Build 42',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badgeText,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h3.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.overline.copyWith(
            color: AppColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      color: AppColors.border,
    );
  }
}
