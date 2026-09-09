import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../../shared/widgets/error_state_card.dart';
import '../../../shared/widgets/empty_state_card.dart';
import '../../../core/providers/auth_provider.dart';

// Provides list of files in 'resumes' bucket
final resumesProvider = FutureProvider<List<FileObject>>((ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  
  try {
    final List<FileObject> files = await supabase.storage.from('resumes').list(path: user.id);
    return files;
  } catch (e) {
    return [];
  }
});

class ResumeLibraryScreen extends ConsumerWidget {
  const ResumeLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumesAsync = ref.watch(resumesProvider);

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
                const Text('Resume Library', style: AppTextStyles.h4),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            
            // Upload Card
            GestureDetector(
              onTap: () {
                // Future File Picker implementation
              },
              child: GlassCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.15), shape: BoxShape.circle),
                      child: const Icon(LucideIcons.uploadCloud, color: AppColors.accent, size: 24),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Upload New Resume', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                          Text('PDF, DOCX up to 5MB', style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    const Icon(LucideIcons.plus, color: AppColors.primary),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1),
            ),
            
            const SizedBox(height: AppSpacing.xxl),
            
            const Text('Saved Documents', style: AppTextStyles.labelText),
            const SizedBox(height: AppSpacing.md),
            
            resumesAsync.when(
              loading: () => const LoadingState(message: 'Loading resumes...'),
              error: (err, stack) => ErrorStateCard(
                title: 'Library Error',
                message: 'Could not load your saved resumes.',
                onRetry: () => ref.invalidate(resumesProvider),
              ),
              data: (resumes) {
                if (resumes.isEmpty) {
                  return const EmptyStateCard(
                    title: 'No Resumes',
                    description: 'Upload your first resume to get started.',
                    icon: LucideIcons.fileText,
                  ).animate().scale(delay: 200.ms);
                }
                
                return Column(
                  children: resumes.map((file) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _buildResumeItem(file.name, file.updatedAt ?? 'Unknown').animate().fadeIn(),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeItem(String filename, String date) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(LucideIcons.fileText, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(filename, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(date, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          IconButton(icon: const Icon(LucideIcons.moreVertical, color: AppColors.textLight), onPressed: () {}),
        ],
      ),
    );
  }
}
