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

class CareerTargetsScreen extends ConsumerStatefulWidget {
  const CareerTargetsScreen({super.key});

  @override
  ConsumerState<CareerTargetsScreen> createState() => _CareerTargetsScreenState();
}

class _CareerTargetsScreenState extends ConsumerState<CareerTargetsScreen> {
  final _targetRoleController = TextEditingController();
  final _desiredSalaryController = TextEditingController();

  String selectedExperienceLevel = 'Senior';
  String selectedWorkMode = 'Hybrid';

  bool isSaving = false;
  bool isInitialized = false;

  final List<String> experienceLevels = ['Beginner', 'Intermediate', 'Senior', 'Expert'];
  final List<String> workModes = ['Remote', 'Hybrid', 'On-site'];

  @override
  void dispose() {
    _targetRoleController.dispose();
    _desiredSalaryController.dispose();
    super.dispose();
  }

  Future<void> _saveTargets(String userId, String email, String name) async {
    setState(() => isSaving = true);
    final supabase = ref.read(supabaseClientProvider);

    try {
      final payload = {
        'id': userId,
        'email': email,
        'full_name': name,
        'target_role': _targetRoleController.text.trim(),
        'experience_level': selectedExperienceLevel,
        'work_mode': selectedWorkMode,
        'desired_salary': _desiredSalaryController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      try {
        await supabase.from('profiles').upsert(payload);
      } catch (_) {
        await supabase.from('profiles').upsert({
          'id': userId,
          'email': email,
          'full_name': name,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      ref.invalidate(profileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Career targets saved successfully!')),
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
            content: Text('Error saving targets: $e'),
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
        loading: () => const LoadingState(message: 'Loading career targets...'),
        error: (err, stack) => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: ErrorStateCard(
              title: 'Error Loading Targets',
              message: 'Could not load your career target data.',
              onRetry: () => ref.invalidate(profileProvider),
            ),
          ),
        ),
        data: (profile) {
          final fullName =
              profile?['full_name'] ?? user?.email?.split('@')[0] ?? 'Career Professional';
          final email = user?.email ?? '';

          if (!isInitialized) {
            _targetRoleController.text =
                profile?['target_role'] as String? ?? 'Software Engineer';
            _desiredSalaryController.text =
                profile?['desired_salary'] as String? ?? '\$120,000 - \$160,000 / yr';
            if (profile?['experience_level'] != null &&
                experienceLevels.contains(profile!['experience_level'])) {
              selectedExperienceLevel = profile['experience_level'];
            }
            if (profile?['work_mode'] != null &&
                workModes.contains(profile!['work_mode'])) {
              selectedWorkMode = profile['work_mode'];
            }
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
                          Text('Career Targets & Goals', style: AppTextStyles.h3),
                          Text(
                            'Tailors AI resume & interview scoring',
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
                        controller: _targetRoleController,
                        label: 'Target Job Title',
                        hintText: 'e.g. Senior Flutter Developer',
                        icon: LucideIcons.briefcase,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      Text('Target Experience Level', style: AppTextStyles.labelText),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: experienceLevels.map((lvl) {
                          final isSelected = selectedExperienceLevel == lvl;
                          return ChoiceChip(
                            label: Text(lvl),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) setState(() => selectedExperienceLevel = lvl);
                            },
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.surface,
                            labelStyle: AppTextStyles.bodySmall.copyWith(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      Text('Preferred Work Model', style: AppTextStyles.labelText),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: workModes.map((mode) {
                          final isSelected = selectedWorkMode == mode;
                          return ChoiceChip(
                            label: Text(mode),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) setState(() => selectedWorkMode = mode);
                            },
                            selectedColor: AppColors.secondary,
                            backgroundColor: AppColors.surface,
                            labelStyle: AppTextStyles.bodySmall.copyWith(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      PremiumTextField(
                        controller: _desiredSalaryController,
                        label: 'Target Salary Range',
                        hintText: 'e.g. \$130,000 - \$160,000 / yr',
                        icon: LucideIcons.dollarSign,
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      SecondaryButton(
                        text: 'Save Career Targets',
                        icon: LucideIcons.save,
                        isLoading: isSaving,
                        onPressed: user != null
                            ? () => _saveTargets(user.id, email, fullName)
                            : null,
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.08),
              ],
            ),
          );
        },
      ),
    );
  }
}
