import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:career_connect/core/theme/app_colors.dart';
import 'package:career_connect/core/theme/app_typography.dart';
import 'package:career_connect/core/utils/extensions.dart';
import 'package:career_connect/core/utils/status_helper.dart';
import 'package:career_connect/features/applications/data/models/application_model.dart';
import 'package:career_connect/features/applications/presentation/bloc/applications_bloc.dart';
import 'package:career_connect/shared/widgets/app_button.dart';
import 'package:career_connect/shared/widgets/app_widgets.dart';

class ApplicantDetailScreen extends StatefulWidget {
  final String applicationId;
  const ApplicantDetailScreen({super.key, required this.applicationId});
  @override
  State<ApplicantDetailScreen> createState() => _ApplicantDetailScreenState();
}

class _ApplicantDetailScreenState extends State<ApplicantDetailScreen> {
  ApplicationModel? _application;

  @override
  void initState() {
    super.initState();
    final state = context.read<ApplicationsBloc>().state;
    try {
      _application = state.applications.firstWhere((a) => a.id == widget.applicationId);
    } catch (_) {}
  }

  void _updateStatus(String status) {
    context.read<ApplicationsBloc>().add(
        UpdateApplicationStatusEvent(applicationId: widget.applicationId, status: status));
    setState(() {
      _application = _application?.copyWith(status: status);
    });
    context.showSnackBar('Status updated to ${StatusHelper.getStatusLabel(status)}');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    if (_application == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => context.pop()),
          title: const Text('Applicant'),
        ),
        body: const Center(child: Text('Application not found')),
      );
    }

    final app = _application!;
    final statusColor = StatusHelper.getStatusColor(app.status);

    return BlocListener<ApplicationsBloc, ApplicationsState>(
      listener: (context, state) {
        if (state.error != null) context.showSnackBar(state.error!, isError: true);
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
          title: Text('Applicant Detail', style: AppTextStyles.headlineMedium),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student hero card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [AppColors.darkCard, AppColors.darkSurface]
                        : [AppColors.primaryLight, Colors.white],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Column(children: [
                  ProfileAvatar(name: app.studentName, imageUrl: app.studentPhotoUrl, radius: 40),
                  const SizedBox(height: 14),
                  Text(app.studentName, style: AppTextStyles.headlineLarge),
                  const SizedBox(height: 4),
                  Text(app.studentEmail,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                  const SizedBox(height: 14),
                  StatusChip(status: app.status),
                ]),
              ).animate().fade(duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),

              const SizedBox(height: 20),

              // Application info
              _InfoCard(
                title: 'Application Info',
                children: [
                  _Row(Icons.work_outline_rounded, 'Job Title', app.jobTitle),
                  _Row(Icons.business_outlined, 'Company', app.companyName),
                  _Row(Icons.schedule_rounded, 'Applied', app.appliedAt.toFormattedDateTime()),
                  if (app.updatedAt != null)
                    _Row(Icons.update_rounded, 'Last Updated', app.updatedAt!.toFormattedDateTime()),
                ],
              ).animate().fade(delay: 150.ms),

              const SizedBox(height: 16),

              // Cover letter
              if (app.coverLetter != null && app.coverLetter!.isNotEmpty)
                _InfoCard(
                  title: 'Cover Letter',
                  children: [
                    Text(app.coverLetter!,
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            height: 1.7)),
                  ],
                ).animate().fade(delay: 200.ms),

              if (app.coverLetter != null && app.coverLetter!.isNotEmpty) const SizedBox(height: 16),

              // Resume
              if (app.resumeUrl != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Resume', style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 12),
                    Row(children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.error, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Resume.pdf', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                          Text('Tap to view', style: AppTextStyles.caption.copyWith(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                        ]),
                      ),
                      IconButton(
                        icon: const Icon(Icons.download_rounded, color: AppColors.primary),
                        onPressed: () async {
                          final uri = Uri.parse(app.resumeUrl!);
                          if (await canLaunchUrl(uri)) await launchUrl(uri);
                        },
                      ),
                    ]),
                  ]),
                ).animate().fade(delay: 250.ms),

              if (app.resumeUrl != null) const SizedBox(height: 20),

              // Action buttons
              Text('Update Status', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 12),

              // Current status indicator
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.2)),
                ),
                child: Row(children: [
                  Icon(StatusHelper.getStatusIcon(app.status), color: statusColor, size: 20),
                  const SizedBox(width: 10),
                  Text('Current status: ${StatusHelper.getStatusLabel(app.status)}',
                      style: AppTextStyles.bodySmall.copyWith(color: statusColor, fontWeight: FontWeight.w600)),
                ]),
              ).animate().fade(delay: 300.ms),

              const SizedBox(height: 16),

              // Action buttons
              if (app.status != 'accepted' && app.status != 'rejected') ...[
                if (app.status != 'shortlisted')
                  AppButton(
                    label: 'Shortlist Candidate',
                    icon: Icons.star_rounded,
                    outlined: true,
                    onPressed: () => _updateStatus('shortlisted'),
                  ).animate().fade(delay: 350.ms),
                const SizedBox(height: 10),
                AppButton(
                  label: 'Accept Candidate',
                  icon: Icons.check_circle_rounded,
                  onPressed: () => _showConfirmDialog(
                    'Accept Candidate',
                    'Are you sure you want to accept ${app.studentName}?',
                    () => _updateStatus('accepted'),
                  ),
                ).animate().fade(delay: 400.ms),
                const SizedBox(height: 10),
                AppButton(
                  label: 'Reject Candidate',
                  icon: Icons.cancel_rounded,
                  outlined: true,
                  onPressed: () => _showConfirmDialog(
                    'Reject Candidate',
                    'Are you sure you want to reject ${app.studentName}? This action cannot be undone.',
                    () => _updateStatus('rejected'),
                  ),
                ).animate().fade(delay: 450.ms),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: statusColor.withOpacity(0.25)),
                  ),
                  child: Column(children: [
                    Icon(StatusHelper.getStatusIcon(app.status), color: statusColor, size: 40),
                    const SizedBox(height: 8),
                    Text('Application ${StatusHelper.getStatusLabel(app.status)}',
                        style: AppTextStyles.headlineSmall.copyWith(color: statusColor)),
                    const SizedBox(height: 4),
                    Text(app.status == 'accepted'
                        ? 'This candidate has been accepted for the role'
                        : 'This application has been rejected',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        textAlign: TextAlign.center),
                  ]),
                ).animate().fade(delay: 350.ms),
              ],

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmDialog(String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () { Navigator.pop(context); onConfirm(); },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.headlineSmall),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Row(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 10),
        Text('$label: ',
            style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
        Expanded(
          child: Text(value,
              style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      ]),
    );
  }
}
