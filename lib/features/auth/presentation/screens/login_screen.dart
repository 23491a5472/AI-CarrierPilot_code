import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/premium_text_field.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/profile_provider.dart';
import '../../../../core/providers/limits_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool isLoading = false;

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => isLoading = true);
    final supabase = ref.read(supabaseClientProvider);
    try {
      if (isLogin) {
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } else {
        final authRes = await supabase.auth.signUp(
          email: email,
          password: password,
          data: {'full_name': name},
        );

        final userId = authRes.user?.id;
        if (userId != null) {
          // Initialize DB Profile, Usage Limits, and Subscription Status
          await supabase.from('profiles').upsert({
            'id': userId,
            'email': email,
            'full_name': name.isNotEmpty ? name : email.split('@')[0],
          });

          await supabase.from('subscription_status').upsert({
            'user_id': userId,
            'plan_type': 'free',
            'is_active': true,
          });

          await supabase.from('user_usage_limits').upsert({
            'user_id': userId,
            'ats_scans_used_today': 0,
            'cover_letters_used_today': 0,
            'resume_improvements_used_today': 0,
            'last_reset_date': DateTime.now().toIso8601String().split('T')[0],
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created successfully!')),
          );
        }
      }

      // Invalidate Riverpod providers to force dynamic re-fetch
      ref.invalidate(profileProvider);
      ref.invalidate(subscriptionProvider);
      ref.invalidate(usageLimitsProvider);

      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception:', '').trim()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: AppCard(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    LucideIcons.compass,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  isLogin ? 'Welcome back.' : 'Create account.',
                  style: AppTextStyles.h1,
                ),
                const SizedBox(height: 4),
                Text(
                  isLogin
                      ? 'Sign in to access your resume & application insights.'
                      : 'Create your account to start managing your career journey.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (!isLogin) ...[
                  PremiumTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    hintText: 'Enter your full name',
                    icon: LucideIcons.user,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                PremiumTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hintText: 'name@example.com',
                  icon: LucideIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSpacing.md),
                PremiumTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hintText: 'Enter your password',
                  icon: LucideIcons.lock,
                  obscureText: true,
                ),
                const SizedBox(height: AppSpacing.xl),
                GradientButton(
                  text: isLogin ? 'Sign In' : 'Create Account',
                  onPressed: _submit,
                  isLoading: isLoading,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLogin
                          ? "Don't have an account? "
                          : "Already have an account? ",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => isLogin = !isLogin),
                      child: Text(
                        isLogin ? 'Sign Up' : 'Sign In',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
