import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:career_connect/core/router/app_router.dart';
import 'package:career_connect/core/theme/app_colors.dart';
import 'package:career_connect/core/theme/app_typography.dart';
import 'package:career_connect/core/utils/extensions.dart';
import 'package:career_connect/core/utils/status_helper.dart';
import 'package:career_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:career_connect/features/jobs/data/models/job_model.dart';
import 'package:career_connect/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:career_connect/shared/widgets/app_widgets.dart';
import 'package:career_connect/shared/widgets/skeleton_loader.dart';

class ManageJobsScreen extends StatefulWidget {
  const ManageJobsScreen({super.key});
  @override
  State<ManageJobsScreen> createState() => _ManageJobsScreenState();
}

class _ManageJobsScreenState extends State<ManageJobsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      context.read<JobsBloc>().add(
          JobsLoadHome(skills: const [], userId: auth.user.uid));
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        elevation: 0,
        title: Text('Manage Jobs', style: AppTextStyles.headlineLarge),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
            ),
            onPressed: () => context.push(AppRoutes.createJob),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          tabs: const [Tab(text: 'Active'), Tab(text: 'Closed')],
        ),
      ),
      body: BlocBuilder<JobsBloc, JobsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: SkeletonLoader(height: 120)),
            );
          }
          if (state.error != null) {
            return ErrorView(message: state.error!);
          }
          return TabBarView(
            controller: _tabCtrl,
            children: [
              _JobsList(
                jobs: state.jobs.where((j) => j.status == 'active').toList(),
                emptyTitle: 'No active jobs',
                emptySubtitle: 'Post your first job to attract candidates',
                actionLabel: 'Post a Job',
                onAction: () => context.push(AppRoutes.createJob),
              ),
              _JobsList(
                jobs: state.jobs.where((j) => j.status == 'closed').toList(),
                emptyTitle: 'No closed jobs',
                emptySubtitle: 'Closed job listings will appear here',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _JobsList extends StatelessWidget {
  final List<JobModel> jobs;
  final String emptyTitle;
  final String emptySubtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _JobsList({
    required this.jobs,
    required this.emptyTitle,
    required this.emptySubtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return EmptyState(
        icon: Icons.work_off_outlined,
        title: emptyTitle,
        subtitle: emptySubtitle,
        actionLabel: actionLabel,
        onAction: onAction,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      itemBuilder: (ctx, i) => _EmployerJobCard(
        job: jobs[i],
        onTap: () => context.push('/employer/jobs/${jobs[i].id}/applicants'),
      ).animate().fade(delay: (i * 60).ms).slideY(begin: 0.08),
    );
  }
}

class _EmployerJobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onTap;
  const _EmployerJobCard({required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final typeColor = StatusHelper.getJobTypeColor(job.jobType);
    final isExpired = job.isExpired;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text(job.title,
                    style: AppTextStyles.headlineSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (job.status == 'active' ? AppColors.success : AppColors.error)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  job.status == 'active' ? 'Active' : 'Closed',
                  style: AppTextStyles.caption.copyWith(
                      color: job.status == 'active'
                          ? AppColors.success
                          : AppColors.error,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              if (job.location != null) ...[
                Icon(Icons.location_on_outlined,
                    size: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
                const SizedBox(width: 4),
                Text(job.location!,
                    style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary)),
                const SizedBox(width: 12),
              ],
              Icon(Icons.people_outline_rounded,
                  size: 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
              const SizedBox(width: 4),
              Text('${job.applicantCount} applicants',
                  style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(job.jobType,
                    style: AppTextStyles.caption.copyWith(
                        color: typeColor, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(job.category,
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              Text(
                isExpired
                    ? 'Expired'
                    : 'Closes ${job.deadline.toFormattedDate()}',
                style: AppTextStyles.caption.copyWith(
                    color: isExpired ? AppColors.error : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.people_outline_rounded, size: 16),
                  label: Text('View Applicants (${job.applicantCount})'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      visualDensity: VisualDensity.compact),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
