import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/gradient_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Master Your Resume',
      'subtitle': 'AI-POWERED RESUME AUDIT',
      'description':
          'Elevate your profile with precision ATS feedback. Compare your experience directly to top market requirements.',
      'icon': LucideIcons.fileText,
    },
    {
      'title': 'Tailored Cover Letters',
      'subtitle': 'PERSONALIZED APPLICANT MATCHING',
      'description':
          'Generate professional, compelling cover letters that capture your unique career trajectory and value.',
      'icon': LucideIcons.penTool,
    },
    {
      'title': 'Interview Coaching',
      'subtitle': 'ROLE-SPECIFIC PREPARATION',
      'description':
          'Walk into every interview with clarity using practice scenarios, key question breakdowns, and tailored answers.',
      'icon': LucideIcons.messageSquare,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, top: 12),
              child: TextButton(
                onPressed: () => context.go('/login'),
                child: Text(
                  'Skip',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppCard(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.softTerracotta.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                page['icon'] as IconData,
                                size: 56,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              (page['subtitle'] as String).toUpperCase(),
                              style: AppTextStyles.overline.copyWith(
                                color: AppColors.primary,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ).animate().scale(curve: Curves.easeOutCubic, duration: 500.ms),
                      const SizedBox(height: 32),
                      Text(
                        page['title'] as String,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h2,
                      ).animate().slideY(begin: 0.1).fadeIn(),
                      const SizedBox(height: 12),
                      Text(
                        page['description'] as String,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ).animate().slideY(begin: 0.1, delay: 100.ms).fadeIn(),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 6,
                      width: _currentIndex == index ? 24 : 6,
                      decoration: BoxDecoration(
                        color: _currentIndex == index
                            ? AppColors.primary
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                GradientButton(
                  text: _currentIndex == _pages.length - 1
                      ? 'Get Started'
                      : 'Continue',
                  onPressed: () {
                    if (_currentIndex == _pages.length - 1) {
                      context.go('/login');
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
