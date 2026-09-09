import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/usage_limit_badge.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../../shared/widgets/premium_bottom_nav.dart';
import '../../../core/providers/limits_provider.dart';
import '../../analyze/data/analyze_repository.dart';

class AnalyzeScreen extends ConsumerStatefulWidget {
  const AnalyzeScreen({super.key});

  @override
  ConsumerState<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends ConsumerState<AnalyzeScreen> {
  bool isUploading = false;
  String? resumePath;
  String? jobDescription;

  Future<void> _analyze() async {
    final limitsAsync = ref.read(usageLimitsProvider);
    final isPremium = ref.read(isPremiumProvider);
    
    // Limits check
    if (!isPremium && limitsAsync.value != null) {
      final scansUsed = limitsAsync.value!['ats_scans_used_today'] as int? ?? 0;
      if (scansUsed >= 2) {
        context.push('/premium');
        return;
      }
    }

    if (resumePath == null || jobDescription == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload resume and job description.')));
      return;
    }

    setState(() => isUploading = true);
    try {
      final repo = ref.read(analyzeRepositoryProvider);
      final result = await repo.analyzeResume(resumePath!, jobDescription!);
      if (mounted) context.push('/ats_result', extra: result);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final limitsAsync = ref.watch(usageLimitsProvider);
    final isPremium = ref.watch(isPremiumProvider);

    return AppScaffold(
      bottomNavigationBar: const PremiumBottomNav(currentIndex: 1),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Optimize Your\nApplication', style: AppTextStyles.h1),
            const SizedBox(height: AppSpacing.xl),
            
            limitsAsync.when(
              data: (limits) {
                final used = limits?['ats_scans_used_today'] as int? ?? 0;
                return isPremium ? const SizedBox.shrink() : UsageLimitBadge(
                  used: used, limit: 2,
                  onUpgrade: () => context.push('/premium'),
                ).animate().fadeIn().slideX(begin: -0.1);
              },
              loading: () => const SkeletonLoader(height: 50, width: double.infinity),
              error: (_, __) => const SizedBox.shrink(),
            ),
            
            const SizedBox(height: AppSpacing.xxl),
            
            GestureDetector(
              onTap: () {
                // Mock selection
                setState(() => resumePath = 'mock/path/resume.pdf');
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Resume attached (mock)')));
              },
              child: _buildUploadCard(
                title: resumePath != null ? 'Resume Attached' : 'Your Resume', 
                subtitle: resumePath != null ? resumePath! : 'Upload PDF or DOCX', 
                icon: LucideIcons.fileText, 
                color: resumePath != null ? AppColors.success : AppColors.secondary, 
                delay: 200,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            GestureDetector(
              onTap: () {
                setState(() => jobDescription = 'Senior PM role at Apple');
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job Description added (mock)')));
              },
              child: _buildUploadCard(
                title: jobDescription != null ? 'Role Added' : 'Target Role', 
                subtitle: jobDescription != null ? 'Senior PM role at Apple' : 'Paste job description', 
                icon: LucideIcons.briefcase, 
                color: jobDescription != null ? AppColors.success : AppColors.accent, 
                delay: 300,
              ),
            ),

            const SizedBox(height: AppSpacing.huge),
            
            GradientButton(
              text: 'Analyze Match',
              icon: LucideIcons.sparkles,
              isLoading: isUploading,
              onPressed: _analyze,
            ).animate().fadeIn(delay: 500.ms).scale(),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard({required String title, required String subtitle, required IconData icon, required Color color, required int delay}) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.h4),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.textInverse, shape: BoxShape.circle, boxShadow: AppShadows.softCard),
            child: const Icon(LucideIcons.plus, color: AppColors.primary, size: 20),
          )
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.1);
  }
}
