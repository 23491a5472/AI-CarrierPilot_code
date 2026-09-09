import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_button.dart';

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
      'description': 'Elevate your profile with precision feedback. We compare your experience to the market\'s top roles.',
      'icon': LucideIcons.fileText,
      'gradient': AppGradients.heroGradient,
    },
    {
      'title': 'Bespoke Letters',
      'description': 'Generate beautiful, human-sounding cover letters that capture your unique voice and ambition.',
      'icon': LucideIcons.penTool,
      'gradient': AppGradients.amberGradient,
    },
    {
      'title': 'Interview Prep',
      'description': 'Walk into any room with confidence using tailored practice scenarios and expert coaching.',
      'icon': LucideIcons.coffee,
      'gradient': AppGradients.successGradient,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      hasTopBlob: false, // Custom background
      body: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).size.height * 0.1,
            left: -50,
            child: Container(
              width: 350, height: 350,
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppGradients.blobCoral(0.2)),
            ),
          ).animate(target: _currentIndex.toDouble()).fade(duration: 500.ms),
          
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentIndex = index),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GlassCard(
                            padding: EdgeInsets.zero,
                            borderRadius: BorderRadius.circular(48),
                            child: SizedBox(
                              width: 280, height: 320,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.all(AppSpacing.xl),
                                  decoration: BoxDecoration(
                                    gradient: _pages[index]['gradient'],
                                    shape: BoxShape.circle,
                                    boxShadow: AppShadows.iconFloating,
                                  ),
                                  child: Icon(_pages[index]['icon'], size: 80, color: AppColors.textInverse),
                                ),
                              ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: -5, end: 5, duration: 3.seconds),
                            ),
                          ).animate().scale(curve: Curves.easeOutBack, duration: 600.ms),
                          const SizedBox(height: AppSpacing.huge),
                          Text(_pages[index]['title'], textAlign: TextAlign.center, style: AppTextStyles.h2).animate().slideY(begin: 0.1).fadeIn(),
                          const SizedBox(height: AppSpacing.md),
                          Text(_pages[index]['description'], textAlign: TextAlign.center, style: AppTextStyles.bodyLarge).animate().slideY(begin: 0.1, delay: 100.ms).fadeIn(),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                          height: 8,
                          width: _currentIndex == index ? 32 : 8,
                          decoration: BoxDecoration(
                            gradient: _currentIndex == index ? _pages[_currentIndex]['gradient'] : null,
                            color: _currentIndex == index ? null : AppColors.textLight.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    GradientButton(
                      text: _currentIndex == _pages.length - 1 ? 'Begin Journey' : 'Continue',
                      onPressed: () {
                        if (_currentIndex == _pages.length - 1) {
                          context.go('/login');
                        } else {
                          _pageController.nextPage(duration: const Duration(milliseconds: 600), curve: Curves.easeOutQuint);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text('Skip for now', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
