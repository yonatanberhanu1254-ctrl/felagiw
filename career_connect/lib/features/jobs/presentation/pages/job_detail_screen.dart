import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:readmore/readmore.dart';
import 'package:uuid/uuid.dart';
import 'package:career_connect/core/theme/app_colors.dart';
import 'package:career_connect/core/theme/app_typography.dart';
import 'package:career_connect/core/utils/extensions.dart';
import 'package:career_connect/core/utils/status_helper.dart';
import 'package:career_connect/features/applications/data/models/application_model.dart';
import 'package:career_connect/features/applications/presentation/bloc/applications_bloc.dart';
import 'package:career_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:career_connect/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:career_connect/features/saved_jobs/presentation/cubit/saved_jobs_cubit.dart';
import 'package:career_connect/shared/widgets/app_button.dart';
import 'package:career_connect/shared/widgets/app_widgets.dart';
import 'package:career_connect/shared/widgets/skeleton_loader.dart';

class JobDetailScreen extends StatefulWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});
  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  final _coverCtrl = TextEditingController();
  bool _showApplySheet = false;

  @override
  void initState() {
    super.initState();
    context.read<JobDetailCubit>().load(widget.jobId);
  }

  @override
  void dispose() {
    _coverCtrl.dispose();
    super.dispose();
  }

  void _applyForJob() {
    final auth = context.read<AuthBloc>().state;
    final detailState = context.read<JobDetailCubit>().state;
    if (auth is! AuthAuthenticated || detailState.job == null) return;

    final job = detailState.job!;
    final application = ApplicationModel(
      id: const Uuid().v4(),
      jobId: job.id,
      jobTitle: job.title,
      companyName: job.companyName,
      companyLogoUrl: job.companyLogoUrl,
      studentId: auth.user.uid,
      studentName: auth.user.name,
      studentEmail: auth.user.email,
      studentPhotoUrl: auth.user.photoUrl,
      employerId: job.employerId,
      coverLetter: _coverCtrl.text.trim().isEmpty ? null : _coverCtrl.text.trim(),
      resumeUrl: auth.user.resumeUrl,
      appliedAt: DateTime.now(),
    );
    context.read<ApplicationsBloc>().add(SubmitApplication(application));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return BlocListener<ApplicationsBloc, ApplicationsState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          context.read<JobDetailCubit>().setHasApplied(true);
          context.showSnackBar('Application submitted! 🎉');
          setState(() => _showApplySheet = false);
        }
        if (state.error != null) {
          context.showSnackBar(state.error!, isError: true);
        }
      },
      child: BlocBuilder<JobDetailCubit, JobDetailState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
            body: state.isLoading
                ? const _LoadingSkeleton()
                : state.error != null
                    ? ErrorView(
                        message: state.error!,
                        onRetry: () =>
                            context.read<JobDetailCubit>().load(widget.jobId))
                    : state.job == null
                        ? const Center(child: Text('Job not found'))
                        : _JobDetailBody(
                            state: state,
                            isDark: isDark,
                            showApplySheet: _showApplySheet,
                            coverCtrl: _coverCtrl,
                            onToggleApply: () =>
                                setState(() => _showApplySheet = !_showApplySheet),
                            onSubmitApply: _applyForJob,
                          ),
          );
        },
      ),
    );
  }
}

class _JobDetailBody extends StatelessWidget {
  final JobDetailState state;
  final bool isDark;
  final bool showApplySheet;
  final TextEditingController coverCtrl;
  final VoidCallback onToggleApply;
  final VoidCallback onSubmitApply;

  const _JobDetailBody({
    required this.state,
    required this.isDark,
    required this.showApplySheet,
    required this.coverCtrl,
    required this.onToggleApply,
    required this.onSubmitApply,
  });

  @override
  Widget build(BuildContext context) {
    final job = state.job!;
    return CustomScrollView(
      slivers: [
        // Hero app bar
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
            ),
            onPressed: () => context.pop(),
          ),
          actions: [
            BlocBuilder<SavedJobsCubit, SavedJobsState>(
              builder: (ctx, saved) => IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1), blurRadius: 8)
                    ],
                  ),
                  child: Icon(
                    saved.isSaved(job.id)
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    size: 18,
                    color: saved.isSaved(job.id)
                        ? AppColors.primary
                        : null,
                  ),
                ),
                onPressed: () {
                  final auth = context.read<AuthBloc>().state;
                  if (auth is AuthAuthenticated) {
                    ctx.read<SavedJobsCubit>().toggleSave(
                        studentId: auth.user.uid, job: job);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [AppColors.darkCard, AppColors.darkSurface]
                      : [AppColors.primaryLight, Colors.white],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBorder : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12)
                      ],
                    ),
                    child: Center(
                      child: Text(
                        job.companyName.isNotEmpty ? job.companyName[0] : 'C',
                        style: AppTextStyles.displaySmall
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(job.companyName,
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary)),
                ],
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(job.title, style: AppTextStyles.displaySmall)
                    .animate()
                    .fade(duration: 400.ms)
                    .slideY(begin: 0.2),
                const SizedBox(height: 12),

                // Tags row
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _tag(job.jobType,
                        StatusHelper.getJobTypeColor(job.jobType)),
                    _tag(job.category, AppColors.secondary),
                    if (job.remote) _tag('Remote', AppColors.info),
                    _tag(job.experienceLevel, AppColors.warning),
                  ],
                ).animate().fade(delay: 100.ms),
                const SizedBox(height: 20),

                // Info cards
                Row(children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.payments_outlined,
                      label: 'Salary',
                      value: job.salaryDisplay,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      value: job.location ?? 'Remote',
                      color: AppColors.primary,
                    ),
                  ),
                ]).animate().fade(delay: 200.ms),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.people_outline_rounded,
                      label: 'Applicants',
                      value: job.applicantCount.toString(),
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.calendar_today_outlined,
                      label: 'Deadline',
                      value: job.deadline.toFormattedDate(),
                      color: job.isExpired ? AppColors.error : AppColors.warning,
                    ),
                  ),
                ]).animate().fade(delay: 250.ms),
                const SizedBox(height: 24),

                // Description
                Text('Job Description', style: AppTextStyles.headlineSmall)
                    .animate()
                    .fade(delay: 300.ms),
                const SizedBox(height: 8),
                ReadMoreText(
                  job.description,
                  trimLines: 5,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: ' Read more',
                  trimExpandedText: ' Show less',
                  moreStyle:
                      AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
                  lessStyle:
                      AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    height: 1.7,
                  ),
                ).animate().fade(delay: 350.ms),

                // Requirements
                if (job.requirements != null && job.requirements!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text('Requirements', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 8),
                  ReadMoreText(
                    job.requirements!,
                    trimLines: 4,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: ' Read more',
                    trimExpandedText: ' Show less',
                    moreStyle: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.primary),
                    lessStyle: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.primary),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      height: 1.7,
                    ),
                  ).animate().fade(delay: 400.ms),
                ],

                // Skills
                if (job.skills.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text('Required Skills', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: job.skills
                        .map((s) => Chip(
                              label: Text(s,
                                  style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600)),
                              backgroundColor:
                                  AppColors.primary.withOpacity(0.1),
                              side: BorderSide(
                                  color: AppColors.primary.withOpacity(0.2)),
                              padding: EdgeInsets.zero,
                            ))
                        .toList(),
                  ).animate().fade(delay: 450.ms),
                ],

                const SizedBox(height: 24),

                // Apply cover letter (inline sheet)
                if (showApplySheet) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cover Letter (Optional)',
                            style: AppTextStyles.headlineSmall),
                        const SizedBox(height: 12),
                        TextField(
                          controller: coverCtrl,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText:
                                'Tell the employer why you are a great fit...',
                            hintStyle: AppTextStyles.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AppColors.primary, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        BlocBuilder<ApplicationsBloc, ApplicationsState>(
                          builder: (_, appState) => AppButton(
                            label: 'Submit Application',
                            isLoading: appState.isSubmitting,
                            onPressed: onSubmitApply,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade(duration: 300.ms).slideY(begin: 0.1),
                ],

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tag(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: AppTextStyles.labelSmall
                .copyWith(color: color, fontWeight: FontWeight.w600)),
      );
}

// ── Apply bottom button (pinned) ──────────────────────────────────────────────
// The CTA is rendered as a persistent bottom via the parent Scaffold.
// We overlay it via a Stack inside the route.

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(label,
              style: AppTextStyles.caption.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary)),
          const SizedBox(height: 2),
          Text(value,
              style: AppTextStyles.bodySmall
                  .copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            const SkeletonLoader(height: 200),
            const SizedBox(height: 20),
            const SkeletonLoader(height: 32, width: 200),
            const SizedBox(height: 12),
            const SkeletonLoader(height: 20, width: 300),
            const SizedBox(height: 20),
            Row(children: const [
              Expanded(child: SkeletonLoader(height: 80)),
              SizedBox(width: 12),
              Expanded(child: SkeletonLoader(height: 80)),
            ]),
          ],
        ),
      ),
    );
  }
}
