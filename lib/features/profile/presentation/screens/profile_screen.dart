import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/premium_text_field.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/premium_bottom_nav.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../../shared/widgets/error_state_card.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/limits_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final user = ref.watch(currentUserProvider);

    return AppScaffold(
      bottomNavigationBar: const PremiumBottomNav(currentIndex: 3),
      body: profileAsync.when(
        loading: () => const LoadingState(message: 'Loading profile...'),
        error: (err, stack) => Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Center(
            child: ErrorStateCard(
              title: 'Profile Error',
              message: 'Could not load your profile data.',
              onRetry: () => ref.invalidate(profileProvider),
            ),
          ),
        ),
        data: (profile) {
          final fullName = profile?['full_name'] ?? user?.email?.split('@')[0] ?? 'User';
          final email = user?.email ?? '';
          final initials = fullName.isNotEmpty ? fullName.substring(0, 1).toUpperCase() : 'U';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Your Profile'),
                const SizedBox(height: AppSpacing.xxl),
                
                // Profile Header Glass Card
                Center(
                  child: GlassCard(
                    child: Column(
                      children: [
                        Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppGradients.heroGradient,
                            boxShadow: AppShadows.iconFloating,
                          ),
                          child: Center(child: Text(initials, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textInverse))),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(fullName, style: AppTextStyles.h3),
                        Text('CareerPilot AI User', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: AppSpacing.lg),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
                          decoration: BoxDecoration(color: (isPremium ? AppColors.accent : AppColors.textLight).withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                          child: Text(isPremium ? 'Premium Plan' : 'Free Plan', style: AppTextStyles.tag.copyWith(color: isPremium ? AppColors.accent : AppColors.textSecondary)),
                        )
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1),
                ),
                
                const SizedBox(height: AppSpacing.xxl),
                
                // Settings Form
                const SectionHeader(title: 'Account Details'),
                const SizedBox(height: AppSpacing.md),
                GlassCard(
                  child: Column(
                    children: [
                      PremiumTextField(
                        controller: TextEditingController(text: email),
                        label: 'Email', hintText: '', icon: LucideIcons.mail,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      PremiumTextField(
                        controller: TextEditingController(text: fullName),
                        label: 'Full Name', hintText: '', icon: LucideIcons.user,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                
                const SizedBox(height: AppSpacing.xxl),
                
                if (!isPremium) ...[
                  // Actions
                  GradientButton(
                    text: 'Upgrade to Premium',
                    icon: LucideIcons.crown,
                    gradient: AppGradients.amberGradient,
                    onPressed: () => context.push('/premium'),
                  ).animate().fadeIn(delay: 400.ms).scale(),
                  const SizedBox(height: AppSpacing.lg),
                ],
                
                Center(
                  child: TextButton(
                    onPressed: () async {
                      await ref.read(supabaseClientProvider).auth.signOut();
                      if (context.mounted) context.go('/login');
                    },
                    child: Text('Sign Out', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.w700)),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
