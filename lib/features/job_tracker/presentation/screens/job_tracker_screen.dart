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
import 'package:careerpilot_ai/shared/widgets/premium_bottom_nav.dart';
import 'package:careerpilot_ai/shared/widgets/loading_state.dart';
import 'package:careerpilot_ai/shared/widgets/error_state_card.dart';
import 'package:careerpilot_ai/shared/widgets/empty_state_card.dart';
import 'package:careerpilot_ai/core/widgets/banner_ad_widget.dart';
import 'package:careerpilot_ai/features/job_tracker/data/job_tracker_repository.dart';

final applicationsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(jobTrackerRepositoryProvider);
  return repo.getApplications();
});

class JobTrackerScreen extends ConsumerStatefulWidget {
  const JobTrackerScreen({super.key});

  @override
  ConsumerState<JobTrackerScreen> createState() => _JobTrackerScreenState();
}

class _JobTrackerScreenState extends ConsumerState<JobTrackerScreen> {
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();

  String _selectedStatus = 'Applied';
  final List<String> statusStages = [
    'Applied',
    'In Review',
    'Interviewing',
    'Offer',
    'Rejected'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  void _showAddJobDialog() {
    _locationController.text = 'Remote';
    _salaryController.text = '\$120k - \$160k';
    _selectedStatus = 'Applied';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
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
                Text('Track New Application', style: AppTextStyles.h3),
                const SizedBox(height: 16),
                PremiumTextField(
                  controller: _titleController,
                  label: 'Job Title',
                  hintText: 'e.g. Senior Flutter Engineer',
                  icon: LucideIcons.briefcase,
                ),
                const SizedBox(height: 12),
                PremiumTextField(
                  controller: _companyController,
                  label: 'Company Name',
                  hintText: 'e.g. Google',
                  icon: LucideIcons.building,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: PremiumTextField(
                        controller: _locationController,
                        label: 'Location / Mode',
                        hintText: 'e.g. Remote / Hybrid',
                        icon: LucideIcons.mapPin,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: PremiumTextField(
                        controller: _salaryController,
                        label: 'Salary Range',
                        hintText: 'e.g. \$130k - \$160k',
                        icon: LucideIcons.dollarSign,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text('Application Stage', style: AppTextStyles.labelText),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: statusStages.map((stg) {
                    final isSel = _selectedStatus == stg;
                    return ChoiceChip(
                      label: Text(stg),
                      selected: isSel,
                      onSelected: (val) {
                        if (val) setModalState(() => _selectedStatus = stg);
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      labelStyle: AppTextStyles.bodySmall.copyWith(
                        color: isSel ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                GradientButton(
                  text: 'Save Application',
                  icon: LucideIcons.check,
                  onPressed: () async {
                    final title = _titleController.text.trim();
                    final company = _companyController.text.trim();

                    if (title.isNotEmpty && company.isNotEmpty) {
                      final repo = ref.read(jobTrackerRepositoryProvider);
                      await repo.addApplication(
                        title: title,
                        company: company,
                        location: _locationController.text.trim(),
                        salaryRange: _salaryController.text.trim(),
                        status: _selectedStatus,
                      );

                      _titleController.clear();
                      _companyController.clear();
                      _locationController.clear();
                      _salaryController.clear();

                      ref.invalidate(applicationsProvider);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showChangeStatusDialog(String jobId, String currentStatus) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Update Application Status', style: AppTextStyles.h3),
            const SizedBox(height: 14),
            Column(
              children: statusStages.map((stg) {
                final isCurrent = currentStatus.toLowerCase() == stg.toLowerCase();
                return ListTile(
                  title: Text(
                    stg,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                      color: isCurrent ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  trailing: isCurrent
                      ? Icon(LucideIcons.check, color: AppColors.primary, size: 20)
                      : null,
                  onTap: () async {
                    Navigator.pop(context);
                    final repo = ref.read(jobTrackerRepositoryProvider);
                    await repo.updateStatus(jobId, stg);
                    ref.invalidate(applicationsProvider);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteJob(String id) async {
    try {
      final repo = ref.read(jobTrackerRepositoryProvider);
      await repo.deleteApplication(id);
      ref.invalidate(applicationsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting job: $e')),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('offer')) return AppColors.success;
    if (lower.contains('interview')) return AppColors.primary;
    if (lower.contains('review')) return AppColors.warning;
    if (lower.contains('reject')) return AppColors.error;
    return AppColors.secondary;
  }

  @override
  Widget build(BuildContext context) {
    final applicationsAsync = ref.watch(applicationsProvider);

    return AppScaffold(
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          BannerAdWidget(),
          PremiumBottomNav(currentIndex: 2),
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
                    Text('Job Tracker', style: AppTextStyles.h1),
                    const SizedBox(height: 2),
                    Text(
                      'Track pipeline & launch AI tools per role',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _showAddJobDialog,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(
                      LucideIcons.plus,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn().slideX(),
            const SizedBox(height: AppSpacing.lg),

            applicationsAsync.when(
              loading: () =>
                  const LoadingState(message: 'Loading your job tracker...'),
              error: (err, stack) => ErrorStateCard(
                title: 'Tracker Error',
                message: 'Could not load your saved applications.',
                onRetry: () => ref.invalidate(applicationsProvider),
              ),
              data: (applications) {
                final totalApps = applications.length;
                final interviewCount = applications
                    .where((a) =>
                        a['status'].toString().toLowerCase().contains('interview'))
                    .length;
                final offerCount = applications
                    .where((a) =>
                        a['status'].toString().toLowerCase().contains('offer'))
                    .length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pipeline Summary Strip
                    if (applications.isNotEmpty) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryBadge(
                              label: 'Total Tracked',
                              value: '$totalApps',
                              icon: LucideIcons.briefcase,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildSummaryBadge(
                              label: 'Interviewing',
                              value: '$interviewCount',
                              icon: LucideIcons.messageSquare,
                              color: AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildSummaryBadge(
                              label: 'Offers',
                              value: '$offerCount',
                              icon: LucideIcons.trophy,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    if (applications.isEmpty)
                      EmptyStateCard(
                        title: 'No Jobs Tracked Yet',
                        description:
                            'Track target positions to unlock custom AI cover letters, interview Q&A prep, and application pipeline management.',
                        icon: LucideIcons.briefcase,
                        action: GradientButton(
                          text: 'Add First Job',
                          icon: LucideIcons.plus,
                          onPressed: _showAddJobDialog,
                        ),
                      ).animate().scale(delay: 150.ms)
                    else
                      Column(
                        children: applications.map((app) {
                          final id = app['id'] as String? ?? '';
                          final title = app['title'] as String? ?? 'Software Engineer';
                          final company = app['company'] as String? ?? 'TechCorp';
                          final location = app['location'] as String? ?? 'Remote';
                          final salary = app['salary_range'] as String? ?? '\$120k - \$160k';
                          final status = app['status'] as String? ?? 'Applied';
                          final statusColor = _getStatusColor(status);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: _buildJobCard(
                              id: id,
                              title: title,
                              company: company,
                              location: location,
                              salary: salary,
                              status: status,
                              statusColor: statusColor,
                            ).animate().fadeIn(),
                          );
                        }).toList(),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBadge({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.h3.copyWith(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildJobCard({
    required String id,
    required String title,
    required String company,
    required String location,
    required String salary,
    required String status,
    required Color statusColor,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Company Icon, Title & Trash
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Icon(
                  LucideIcons.building,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.h4.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      company,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (id.isNotEmpty)
                IconButton(
                  icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.redAccent),
                  onPressed: () => _deleteJob(id),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Metadata Badges Row & Stage Selector Chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildMetaPill(LucideIcons.mapPin, location),
                  const SizedBox(width: 8),
                  _buildMetaPill(LucideIcons.dollarSign, salary),
                ],
              ),
              GestureDetector(
                onTap: id.isNotEmpty ? () => _showChangeStatusDialog(id, status) : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        status.toUpperCase(),
                        style: AppTextStyles.overline.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(LucideIcons.chevronDown, size: 12, color: statusColor),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // 1-Click AI Tool Actions Strip
          Text('Role AI Launchpad', style: AppTextStyles.overline.copyWith(color: AppColors.textMuted, fontSize: 10)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildAiActionButton(
                  icon: LucideIcons.penTool,
                  label: 'Cover Letter',
                  onTap: () => context.push('/cover-letter'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAiActionButton(
                  icon: LucideIcons.messageSquare,
                  label: 'Interview Q&A',
                  onTap: () => context.push('/interview-prep'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAiActionButton(
                  icon: LucideIcons.scanLine,
                  label: 'Scan ATS',
                  onTap: () => context.push('/analyze'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.overline.copyWith(
              color: AppColors.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xs),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppRadius.xs),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: AppColors.primary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
