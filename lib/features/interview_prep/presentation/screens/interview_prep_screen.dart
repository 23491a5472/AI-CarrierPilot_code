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
import 'package:careerpilot_ai/shared/widgets/gradient_button.dart';
import 'package:careerpilot_ai/shared/widgets/premium_text_field.dart';
import 'package:careerpilot_ai/features/interview_prep/data/interview_repository.dart';
import 'package:careerpilot_ai/features/resume_library/presentation/screens/resume_library_screen.dart';
import 'package:careerpilot_ai/core/providers/limits_provider.dart';
import 'package:careerpilot_ai/core/widgets/banner_ad_widget.dart';

class InterviewPrepScreen extends ConsumerStatefulWidget {
  const InterviewPrepScreen({super.key});

  @override
  ConsumerState<InterviewPrepScreen> createState() => _InterviewPrepScreenState();
}

class _InterviewPrepScreenState extends ConsumerState<InterviewPrepScreen> {
  bool isGenerating = false;
  List<Map<String, dynamic>> questionList = [];
  int currentIndex = 0;
  bool isCompleted = false;
  bool isRecording = false;
  bool showSuggestedAnswer = false;

  final _roleController = TextEditingController(text: 'Senior Flutter Developer');
  final _jdController = TextEditingController();
  String selectedCategory = 'Technical & System Design';
  String selectedLevel = 'Senior';
  Map<String, dynamic>? selectedResume;

  final List<String> categories = [
    'Technical & System Design',
    'Behavioral & STAR Method',
    'Leadership & Situational',
    'Comprehensive Fit',
  ];

  final List<String> levels = [
    'Beginner',
    'Intermediate',
    'Senior',
    'Expert',
  ];

  Future<void> _generateQuestions() async {
    final role = _roleController.text.trim();
    if (role.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a target job role')),
      );
      return;
    }

    final isPremium = ref.read(isPremiumProvider);
    if (!isPremium && questionList.isNotEmpty) {
      context.push('/premium');
      return;
    }

    setState(() {
      isGenerating = true;
      showSuggestedAnswer = false;
    });

    try {
      final repo = ref.read(interviewRepositoryProvider);
      final resumeContent = selectedResume?['original_file_name'] ?? '';

      final result = await repo.generateQuestions(
        targetRole: role,
        experienceLevel: selectedLevel,
        resumeText: resumeContent,
        jobDescription: _jdController.text.trim(),
        category: selectedCategory,
      );

      final rawQuestions = result['questions'];
      List<Map<String, dynamic>> parsedList = [];

      if (rawQuestions is List) {
        for (var item in rawQuestions) {
          if (item is Map) {
            parsedList.add(Map<String, dynamic>.from(item));
          } else if (item is String) {
            parsedList.add({
              'question': item,
              'category': selectedCategory,
              'suggested_answer': 'Use the STAR method: Situation, Task, Action, Result to outline your past experience and business impact.',
              'key_tip': 'Focus on your specific personal contribution and metric outcomes.',
            });
          }
        }
      }

      setState(() {
        questionList = parsedList;
        currentIndex = 0;
        isCompleted = false;
      });
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
      if (mounted) setState(() => isGenerating = false);
    }
  }

  void _showConfigDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final activeResumesAsync = ref.watch(activeResumesProvider);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Configure Interview Practice', style: AppTextStyles.h3),
                    const SizedBox(height: 4),
                    Text(
                      'Customize questions based on your target role, resume, or job post.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 16),

                    // Target Role
                    Text('Target Job Role *', style: AppTextStyles.label),
                    const SizedBox(height: 6),
                    PremiumTextField(
                      controller: _roleController,
                      label: '',
                      hintText: 'e.g. Senior Flutter Developer, Product Manager',
                      icon: LucideIcons.briefcase,
                    ),
                    const SizedBox(height: 14),

                    // Experience Level Selection
                    Text('Target Experience Level', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: levels.map((lvl) {
                        final isSelected = selectedLevel == lvl;
                        return ChoiceChip(
                          label: Text(lvl),
                          selected: isSelected,
                          selectedColor: AppColors.primary.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() => selectedLevel = lvl);
                              setModalState(() {});
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Category Selection
                    Text('Interview Category Focus', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((cat) {
                        final isSelected = selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: AppColors.primary.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() => selectedCategory = cat);
                              setModalState(() {});
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Resume Selector
                    Text('Target Resume Context', style: AppTextStyles.label),
                    const SizedBox(height: 6),
                    activeResumesAsync.when(
                      data: (resumes) {
                        if (resumes.isEmpty) {
                          return Text(
                            'No stored resumes found. Questions will target general $selectedCategory.',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                          );
                        }
                        return DropdownButtonFormField<Map<String, dynamic>>(
                          isExpanded: true,
                          initialValue: selectedResume,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                          ),
                          hint: const Text('Select an uploaded resume'),
                          items: resumes.map((res) {
                            return DropdownMenuItem(
                              value: res,
                              child: Text(
                                res['original_file_name'] ?? 'Resume',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => selectedResume = val);
                            setModalState(() {});
                          },
                        );
                      },
                      loading: () => const SizedBox(
                        height: 30,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      error: (err, stack) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 14),

                    // Job Description Optional
                    Text('Target Job Description (Optional)', style: AppTextStyles.label),
                    const SizedBox(height: 6),
                    PremiumTextField(
                      controller: _jdController,
                      label: '',
                      hintText: 'Paste specific job posting requirements here...',
                      icon: LucideIcons.fileText,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    GradientButton(
                      text: 'Generate Interview Questions',
                      icon: LucideIcons.sparkles,
                      isLoading: isGenerating,
                      onPressed: () {
                        Navigator.pop(context);
                        _generateQuestions();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      bottomNavigationBar: const BannerAdWidget(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: 48,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
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
                Text('Mock Interview Prep', style: AppTextStyles.h3),
                const Spacer(),
                IconButton(
                  onPressed: _showConfigDialog,
                  icon: Icon(LucideIcons.sliders, color: AppColors.primary),
                  tooltip: 'Configure Session',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            if (questionList.isEmpty) ...[
              // Setup Card Header
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(LucideIcons.mic, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Role-Specific Mock Interview', style: AppTextStyles.h4),
                              const SizedBox(height: 2),
                              Text(
                                'Practice realistic questions tailored to your target job role & resume.',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Target Job Role', style: AppTextStyles.label),
                    const SizedBox(height: 6),
                    PremiumTextField(
                      controller: _roleController,
                      label: '',
                      hintText: 'e.g. Senior Flutter Engineer, Technical PM',
                      icon: LucideIcons.briefcase,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Target Experience Level', style: AppTextStyles.label),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: levels.map((lvl) {
                        final isSelected = selectedLevel == lvl;
                        return ChoiceChip(
                          label: Text(lvl),
                          selected: isSelected,
                          selectedColor: AppColors.primary.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => selectedLevel = lvl);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Focus Area', style: AppTextStyles.label),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((cat) {
                        final isSelected = selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: AppColors.primary.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => selectedCategory = cat);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    GradientButton(
                      text: 'Generate Interview Questions',
                      icon: LucideIcons.sparkles,
                      isLoading: isGenerating,
                      onPressed: _generateQuestions,
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.08),
            ] else if (isCompleted) ...[
              // Completion View
              _buildCompletionCard().animate().fadeIn().slideY(begin: 0.08),
              const SizedBox(height: 48),
            ] else ...[
              // Active Question Practice Display
              _buildActiveQuestionCard().animate().fadeIn().slideY(begin: 0.08),
              const SizedBox(height: AppSpacing.lg),
              // Practice Voice Audio Card
              _buildVoicePracticeCard().animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 48),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActiveQuestionCard() {
    final currentObj = questionList[currentIndex];
    final qText = currentObj['question'] ?? 'Sample question';
    final qCategory = currentObj['category'] ?? selectedCategory;
    final suggestedAnswer = currentObj['suggested_answer'] as String?;
    final keyTip = currentObj['key_tip'] as String?;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Text(
                  'QUESTION ${currentIndex + 1} OF ${questionList.length}',
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.softTerracotta.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  qCategory,
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.softTerracotta,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            qText,
            style: AppTextStyles.h3.copyWith(height: 1.35),
          ),
          const SizedBox(height: AppSpacing.md),

          // Suggested Answer Accordion
          if (suggestedAnswer != null) ...[
            GestureDetector(
              onTap: () => setState(() => showSuggestedAnswer = !showSuggestedAnswer),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.lightbulb, color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      showSuggestedAnswer ? 'Hide STAR Model Answer' : 'View STAR Model Answer & Tips',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      showSuggestedAnswer ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            if (showSuggestedAnswer) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Model STAR Answer:', style: AppTextStyles.label),
                    const SizedBox(height: 4),
                    Text(
                      suggestedAnswer,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    if (keyTip != null) ...[
                      const SizedBox(height: 10),
                      Text('Pro Tip:', style: AppTextStyles.label.copyWith(color: AppColors.softTerracotta)),
                      const SizedBox(height: 2),
                      Text(
                        keyTip,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],

          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: currentIndex > 0
                    ? () => setState(() {
                          currentIndex--;
                          showSuggestedAnswer = false;
                        })
                    : null,
                icon: const Icon(LucideIcons.chevronLeft, size: 16),
                label: const Text('Previous'),
              ),
              if (currentIndex < questionList.length - 1)
                TextButton.icon(
                  onPressed: () => setState(() {
                    currentIndex++;
                    showSuggestedAnswer = false;
                  }),
                  label: const Text('Next'),
                  icon: const Icon(LucideIcons.chevronRight, size: 16),
                )
              else
                TextButton.icon(
                  onPressed: () => setState(() => isCompleted = true),
                  label: const Text('Finish Session'),
                  icon: const Icon(LucideIcons.checkCircle2, size: 16),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.success,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionCard() {
    final isPremium = ref.watch(isPremiumProvider);
    final role = _roleController.text.trim();

    if (!isPremium) {
      return AppCard(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.crown, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('5 Free Questions Completed!', style: AppTextStyles.h4),
                      const SizedBox(height: 2),
                      Text(
                        'Upgrade to Pro for unlimited AI-generated interview practice, STAR answers, and custom role sets.',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            GradientButton(
              text: 'Upgrade to Pro for Unlimited Questions',
              icon: LucideIcons.crown,
              onPressed: () => context.push('/premium'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: () => setState(() {
                isCompleted = false;
                currentIndex = 0;
              }),
              icon: const Icon(LucideIcons.rotateCcw, size: 16),
              label: const Text('Review 5 Questions Again'),
            ),
          ],
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.checkCircle2, color: AppColors.success, size: 28),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('5 Questions Completed!', style: AppTextStyles.h4),
                    const SizedBox(height: 2),
                    Text(
                      'Great job! Ready to practice another set for $selectedLevel $role?',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          GradientButton(
            text: 'Generate 5 New Questions',
            icon: LucideIcons.sparkles,
            isLoading: isGenerating,
            onPressed: _generateQuestions,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: () => setState(() {
              isCompleted = false;
              currentIndex = 0;
            }),
            icon: const Icon(LucideIcons.rotateCcw, size: 16),
            label: const Text('Review Questions Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildVoicePracticeCard() {
    return AppCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Interactive Practice', style: AppTextStyles.h4),
              TextButton(
                onPressed: _showConfigDialog,
                child: Text(
                  'Change Role / Settings',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isRecording ? 'Recording your answer...' : 'Tap mic to practice your spoken response',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isRecording ? AppColors.error : AppColors.textMuted,
              fontWeight: isRecording ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GestureDetector(
            onTap: () {
              setState(() => isRecording = !isRecording);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isRecording ? AppColors.error : AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isRecording ? AppColors.error : AppColors.primary,
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  isRecording ? LucideIcons.square : LucideIcons.mic,
                  color: isRecording ? Colors.white : AppColors.primary,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
