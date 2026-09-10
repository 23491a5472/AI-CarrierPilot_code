import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:careerpilot_ai/core/theme/app_colors.dart';
import 'package:careerpilot_ai/core/theme/app_text_styles.dart';
import 'package:careerpilot_ai/core/theme/app_spacing.dart';
import 'package:careerpilot_ai/shared/widgets/app_scaffold.dart';
import 'package:careerpilot_ai/shared/widgets/glass_card.dart';
import 'package:careerpilot_ai/shared/widgets/premium_text_field.dart';
import 'package:careerpilot_ai/shared/widgets/secondary_button.dart';
import 'package:careerpilot_ai/shared/widgets/loading_state.dart';
import 'package:careerpilot_ai/shared/widgets/error_state_card.dart';
import 'package:careerpilot_ai/core/providers/profile_provider.dart';
import 'package:careerpilot_ai/core/providers/auth_provider.dart';
import 'package:careerpilot_ai/core/providers/limits_provider.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  final _nameController = TextEditingController();
  bool isSaving = false;
  bool isInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveAccountInfo(String userId, String email) async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    setState(() => isSaving = true);
    final supabase = ref.read(supabaseClientProvider);

    try {
      await supabase.from('profiles').upsert({
        'id': userId,
        'email': email,
        'full_name': newName,
        'updated_at': DateTime.now().toIso8601String(),
      });

      ref.invalidate(profileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account details updated successfully!')),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/profile');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating account: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final user = ref.watch(currentUserProvider);

    return AppScaffold(
      body: profileAsync.when(
        loading: () => const LoadingState(message: 'Loading account settings...'),
        error: (err, stack) => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ErrorStateCard(
              title: 'Error Loading Account',
              message: 'Could not load your account information.',
              onRetry: () => ref.invalidate(profileProvider),
            ),
          ),
        ),
        data: (profile) {
          final fullName =
              profile?['full_name'] ?? user?.email?.split('@')[0] ?? 'Career Professional';
          final email = user?.email ?? '';

          if (!isInitialized) {
            _nameController.text = fullName;
            isInitialized = true;
          }

          return SingleChildScrollView(
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
                          Text('Account Settings', style: AppTextStyles.h3),
                          Text(
                            'Manage user profile & authentication',
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
                      PremiumTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hintText: 'Enter full name',
                        icon: LucideIcons.user,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      PremiumTextField(
                        controller: TextEditingController(text: email),
                        label: 'Email Address (Read-only)',
                        hintText: '',
                        icon: LucideIcons.mail,
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      SecondaryButton(
                        text: 'Save Account Changes',
                        icon: LucideIcons.save,
                        isLoading: isSaving,
                        onPressed: user != null
                            ? () => _saveAccountInfo(user.id, email)
                            : null,
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.08),

                const SizedBox(height: AppSpacing.xl),

                // Danger Zone Card
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.logOut, color: AppColors.error, size: 20),
                          const SizedBox(width: 8),
                          Text('Session Actions', style: AppTextStyles.h4),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign out of your active AI CareerPilot session on this device.',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await ref.read(supabaseClientProvider).auth.signOut();
                          ref.invalidate(profileProvider);
                          ref.invalidate(subscriptionProvider);
                          ref.invalidate(usageLimitsProvider);
                          if (context.mounted) context.go('/login');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
                        ),
                        icon: const Icon(LucideIcons.logOut, size: 16),
                        label: const Text('Sign Out of Account'),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 150.ms),
              ],
            ),
          );
        },
      ),
    );
  }
}
