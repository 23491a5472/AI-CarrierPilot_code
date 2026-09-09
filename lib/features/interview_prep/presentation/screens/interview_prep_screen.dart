import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/empty_state_card.dart';
import '../../interview_prep/data/interview_repository.dart';

class InterviewPrepScreen extends ConsumerStatefulWidget {
  const InterviewPrepScreen({super.key});

  @override
  ConsumerState<InterviewPrepScreen> createState() => _InterviewPrepScreenState();
}

class _InterviewPrepScreenState extends ConsumerState<InterviewPrepScreen> {
  bool isGenerating = false;
  List<String> questions = [];
  int currentIndex = 0;

  Future<void> _generateQuestions() async {
    setState(() => isGenerating = true);
    try {
      final repo = ref.read(interviewRepositoryProvider);
      final result = await repo.generateQuestions('mock_job_description');
      setState(() {
        questions = List<String>.from(result['questions'] ?? []);
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(color: AppColors.textInverse, shape: BoxShape.circle),
                    child: const Icon(LucideIcons.arrowLeft, color: AppColors.primary, size: 20),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                const Text('Mock Interview', style: AppTextStyles.h4),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            if (questions.isEmpty) ...[
              EmptyStateCard(
                title: 'Prepare for Success',
                description: 'We will generate custom interview questions based on your target role.',
                icon: LucideIcons.mic,
                action: GradientButton(text: 'Generate Questions', onPressed: _generateQuestions, isLoading: isGenerating),
              ).animate().fadeIn().slideY(begin: 0.1),
            ] else ...[
              // Current Question Card
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                      child: Text('QUESTION ${currentIndex + 1} OF ${questions.length}', style: AppTextStyles.tag.copyWith(color: AppColors.secondary)),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(questions[currentIndex], style: AppTextStyles.h3),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1),
              
              const SizedBox(height: AppSpacing.xxl),
              
              // Audio Recording UI
              Center(
                child: Column(
                  children: [
                    Text('Tap to record your answer', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: AppSpacing.lg),
                    GestureDetector(
                      onTap: () {
                        if (currentIndex < questions.length - 1) {
                          setState(() => currentIndex++);
                        }
                      },
                      child: Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.error.withOpacity(0.3), width: 2),
                        ),
                        child: const Center(
                          child: Icon(LucideIcons.mic, color: AppColors.error, size: 32),
                        ),
                      ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1.seconds),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),
            ]
          ],
        ),
      ),
    );
  }
}
