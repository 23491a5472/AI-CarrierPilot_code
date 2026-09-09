import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/premium_text_field.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../core/providers/auth_provider.dart';

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
    setState(() => isLoading = true);
    final supabase = ref.read(supabaseClientProvider);
    try {
      if (isLogin) {
        await supabase.auth.signInWithPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await supabase.auth.signUp(
          email: _emailController.text,
          password: _passwordController.text,
          data: {'full_name': _nameController.text},
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created. Checking session...')));
        }
      }
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xxl),
          child: GlassCard(
            padding: EdgeInsets.all(AppSpacing.xxl),
            borderRadius: BorderRadius.circular(40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: AppGradients.amberGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppShadows.iconFloating,
                  ),
                  child: Icon(LucideIcons.sparkles, color: AppColors.textInverse, size: 32),
                ),
                SizedBox(height: AppSpacing.xl),
                Text(isLogin ? 'Welcome back.' : 'Create account.', style: AppTextStyles.h1),
                SizedBox(height: AppSpacing.sm),
                Text(
                  isLogin ? 'Enter your details to access your dashboard.' : 'Sign up to start organizing your career journey.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
                SizedBox(height: AppSpacing.huge),
                
                if (!isLogin) ...[
                  PremiumTextField(controller: _nameController, label: 'Full Name', hintText: 'Enter your name', icon: LucideIcons.user),
                  SizedBox(height: AppSpacing.lg),
                ],
                
                PremiumTextField(controller: _emailController, label: 'Email Address', hintText: 'Enter your email', icon: LucideIcons.mail, keyboardType: TextInputType.emailAddress),
                SizedBox(height: AppSpacing.lg),
                
                PremiumTextField(controller: _passwordController, label: 'Password', hintText: 'Enter your password', icon: LucideIcons.lock, obscureText: true),
                
                if (isLogin) ...[
                  SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text('Forgot Password?', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ] else ...[
                  SizedBox(height: AppSpacing.xl),
                ],
                
                SizedBox(height: AppSpacing.lg),
                GradientButton(
                  text: isLogin ? 'Sign In' : 'Create Account',
                  onPressed: _submit,
                  isLoading: isLoading,
                ),
                
                SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(isLogin ? "Don't have an account? " : "Already have an account? ", style: AppTextStyles.bodySmall),
                    GestureDetector(
                      onTap: () => setState(() => isLogin = !isLogin),
                      child: Text(isLogin ? 'Sign Up' : 'Sign In', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
