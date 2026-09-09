import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';

import '../../../../services/supabase_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final session = SupabaseService.client.auth.currentSession;
      if (session != null) {
        context.go('/home');
      } else {
        context.go('/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.huge, vertical: AppSpacing.massive),
          borderRadius: BorderRadius.circular(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: AppGradients.heroGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.iconFloating,
                ),
                child: Icon(LucideIcons.compass, size: 64, color: AppColors.textInverse),
              ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
              const SizedBox(height: AppSpacing.xl),
              Text('CareerPilot AI', style: AppTextStyles.h1).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
              const SizedBox(height: AppSpacing.sm),
              Text('Your career, elevated.', style: AppTextStyles.bodyMedium).animate().fadeIn(delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
