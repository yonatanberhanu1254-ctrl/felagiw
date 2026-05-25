import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:career_connect/core/theme/app_colors.dart';
import 'package:career_connect/core/theme/app_typography.dart';
import 'package:career_connect/core/utils/extensions.dart';
import 'package:career_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:career_connect/features/saved_jobs/data/models/saved_job_model.dart';
import 'package:career_connect/features/saved_jobs/presentation/cubit/saved_jobs_cubit.dart';
import 'package:career_connect/shared/widgets/app_widgets.dart';
import 'package:career_connect/shared/widgets/skeleton_loader.dart';
import 'package:career_connect/core/utils/status_helper.dart';

class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({super.key});
  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      context.read<SavedJobsCubit>().loadSavedJobs(auth.user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Saved Jobs', style: AppTextStyles.headlineLarge),
      ),
      body: BlocBuilder<SavedJobsCubit, SavedJobsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: JobCardSkeleton()),
            );
          }
          if (state.error != null) {
            return ErrorView(
              message: state.error!,
              onRetry: () {
                final auth = context.read<AuthBloc>().state;
                if (auth is AuthAuthenticated) {
                  context.read<SavedJobsCubit>().loadSavedJobs(auth.user.uid);
                }
              },
            );
          }
          if (state.savedJobs.isEmpty) {
            return const EmptyState(
              icon: Icons.bookmark_border_rounded,
              title: 'No saved jobs',
              subtitle: 'Bookmark jobs you\'re interested in\nto find them here later',
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              final auth = context.read<AuthBloc>().state;
              if (auth is AuthAuthenticated) {
                context.read<SavedJobsCubit>().loadSavedJobs(auth.user.uid);
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.savedJobs.length,
              itemBuilder: (context, i) => _SavedJobCard(
                saved: state.savedJobs[i],
                onTap: () =>
                    context.push('/student/jobs/${state.savedJobs[i].jobId}'),
                onRemove: () {
                  final auth = context.read<AuthBloc>().state;
                  if (auth is AuthAuthenticated) {
                    context.read<SavedJobsCubit>().unsaveJob(
                          studentId: auth.user.uid,
                          jobId: state.savedJobs[i].jobId,
                        );
                  }
                },
              ).animate().fade(delay: (i * 60).ms).slideX(begin: -0.05),
            ),
          );
        },
      ),
    );
  }
}

class _SavedJobCard extends StatelessWidget {
  final SavedJobModel saved;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  const _SavedJobCard(
      {required this.saved, required this.onTap, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final isExpired = saved.jobDeadline.isBefore(DateTime.now());
    return Dismissible(
      key: Key(saved.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
      ),
      onDismissed: (_) => onRemove(),
      child: GestureDetector(
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
          child: Row(
            children: [
              // Company icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    saved.companyName.isNotEmpty
                        ? saved.companyName[0].toUpperCase()
                        : 'C',
                    style: AppTextStyles.headlineMedium
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(saved.jobTitle,
                        style: AppTextStyles.headlineSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(saved.companyName,
                        style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: StatusHelper.getJobTypeColor(saved.jobType)
                              .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(saved.jobType,
                            style: AppTextStyles.caption.copyWith(
                                color: StatusHelper.getJobTypeColor(
                                    saved.jobType),
                                fontWeight: FontWeight.w600)),
                      ),
                      if (saved.remote) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('Remote',
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.info,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        isExpired ? 'Expired' : 'Closes ${saved.jobDeadline.toShortDate()}',
                        style: AppTextStyles.caption.copyWith(
                            color: isExpired
                                ? AppColors.error
                                : isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                      ),
                    ]),
                  ],
                ),
              ),
              // Remove button
              IconButton(
                icon: const Icon(Icons.bookmark_remove_rounded,
                    color: AppColors.error, size: 22),
                onPressed: onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
