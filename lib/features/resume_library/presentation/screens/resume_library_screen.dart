import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:careerpilot_ai/core/theme/app_colors.dart';
import 'package:careerpilot_ai/core/theme/app_radius.dart';
import 'package:careerpilot_ai/core/theme/app_text_styles.dart';
import 'package:careerpilot_ai/core/theme/app_spacing.dart';
import 'package:careerpilot_ai/shared/widgets/app_scaffold.dart';
import 'package:careerpilot_ai/shared/widgets/glass_card.dart';
import 'package:careerpilot_ai/shared/widgets/premium_bottom_nav.dart';
import 'package:careerpilot_ai/shared/widgets/loading_state.dart';
import 'package:careerpilot_ai/shared/widgets/error_state_card.dart';
import 'package:careerpilot_ai/shared/widgets/empty_state_card.dart';
import 'package:careerpilot_ai/core/providers/auth_provider.dart';
import 'package:careerpilot_ai/core/widgets/banner_ad_widget.dart';
import 'package:careerpilot_ai/features/resumes/data/resume_repository.dart';

final activeResumesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.watch(resumeRepositoryProvider);
  return repo.getActiveResumes(user.id);
});

class ResumeLibraryScreen extends ConsumerStatefulWidget {
  const ResumeLibraryScreen({super.key});

  @override
  ConsumerState<ResumeLibraryScreen> createState() => _ResumeLibraryScreenState();
}

class _ResumeLibraryScreenState extends ConsumerState<ResumeLibraryScreen> {

  Future<void> _pickAndUploadResume() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to upload resumes')),
      );
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc', 'txt'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final file = File(filePath);

        setState(() => isUploading = true);

        final repo = ref.read(resumeRepositoryProvider);
        await repo.uploadAndCreateResume(user.id, file);

        ref.invalidate(activeResumesProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Resume uploaded successfully!')),
          );
        }
      }
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
      if (mounted) setState(() => isUploading = false);
    }
  }

  bool isUploading = false;

  Future<void> _deleteResume(String resumeId, String storagePath) async {
    try {
      final repo = ref.read(resumeRepositoryProvider);
      await repo.softDeleteResume(resumeId, storagePath);
      ref.invalidate(activeResumesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resume deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting resume: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final resumesAsync = ref.watch(activeResumesProvider);

    return AppScaffold(
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          BannerAdWidget(),
          PremiumBottomNav(currentIndex: 1),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Resume Library', style: AppTextStyles.h1),
                    const SizedBox(height: 2),
                    Text(
                      'Saved document versions & uploads',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ).animate().fadeIn().slideX(),
            const SizedBox(height: AppSpacing.xl),

            // Upload Card
            GestureDetector(
              onTap: isUploading ? null : _pickAndUploadResume,
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.softTerracotta.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: isUploading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            )
                          : Icon(
                              LucideIcons.uploadCloud,
                              color: AppColors.primary,
                              size: 24,
                            ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUploading ? 'Uploading Resume...' : 'Upload New Resume',
                            style: AppTextStyles.h4,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Select PDF, DOCX, or TXT document',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(LucideIcons.plus, color: AppColors.primary, size: 20),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.08),
            ),

            const SizedBox(height: AppSpacing.xl),

            Text('Saved Documents', style: AppTextStyles.labelText),
            const SizedBox(height: AppSpacing.md),

            resumesAsync.when(
              loading: () =>
                  const LoadingState(message: 'Loading saved resumes...'),
              error: (err, stack) => ErrorStateCard(
                title: 'Library Error',
                message: 'Could not load your saved resumes.',
                onRetry: () => ref.invalidate(activeResumesProvider),
              ),
              data: (resumes) {
                if (resumes.isEmpty) {
                  return const EmptyStateCard(
                    title: 'No Documents Saved',
                    description:
                        'Upload your master resume to start building your career library.',
                    icon: LucideIcons.fileText,
                  ).animate().scale(delay: 150.ms);
                }

                return Column(
                  children: resumes.map((file) {
                    final id = file['id'] as String;
                    final filename = file['original_file_name'] as String? ?? 'Resume Document';
                    final path = file['storage_path'] as String? ?? '';
                    final uploadDate = file['upload_date'] as String? ?? '';
                    final formattedDate = uploadDate.isNotEmpty
                        ? uploadDate.split('T')[0]
                        : 'Uploaded recently';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _buildResumeItem(
                        id: id,
                        filename: filename,
                        date: formattedDate,
                        storagePath: path,
                      ).animate().fadeIn(),
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

  Widget _buildResumeItem({
    required String id,
    required String filename,
    required String date,
    required String storagePath,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            child: Icon(LucideIcons.fileText, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  filename,
                  style: AppTextStyles.h4.copyWith(fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  date,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(LucideIcons.moreVertical, color: AppColors.textMuted, size: 18),
            onSelected: (value) {
              if (value == 'delete') {
                _deleteResume(id, storagePath);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(LucideIcons.trash2, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Resume'),
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
