import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:career_connect/core/router/app_router.dart';
import 'package:career_connect/core/theme/app_colors.dart';
import 'package:career_connect/core/theme/app_typography.dart';
import 'package:career_connect/core/utils/extensions.dart';
import 'package:career_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:career_connect/features/jobs/data/models/job_model.dart';
import 'package:career_connect/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:career_connect/features/saved_jobs/presentation/cubit/saved_jobs_cubit.dart';
import 'package:career_connect/shared/widgets/job_card.dart';
import 'package:career_connect/shared/widgets/skeleton_loader.dart';
import 'package:career_connect/shared/widgets/app_widgets.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});
  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      context.read<JobsBloc>().add(
          JobsLoadHome(skills: auth.user.skills, userId: auth.user.uid));
      context.read<SavedJobsCubit>().loadSavedJobs(auth.user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final auth = context.watch<AuthBloc>().state;
    final firstName =
        auth is AuthAuthenticated ? auth.user.name.split(' ').first : 'there';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => _loadData(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // App bar
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
              elevation: 0,
              title: Row(children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.work_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Text('CareerConnect',
                    style: AppTextStyles.headlineMedium
                        .copyWith(color: AppColors.primary)),
              ]),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => context.push(AppRoutes.notifications),
                ),
                ProfileAvatar(
                  name: firstName,
                  imageUrl: auth is AuthAuthenticated
                      ? auth.user.photoUrl
                      : null,
                  radius: 16,
                  onTap: () => context.push(AppRoutes.studentProfile),
                ),
                const SizedBox(width: 12),
              ],
            ),

            // Greeting + search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello, $firstName 👋',
                        style: AppTextStyles.displaySmall)
                        .animate()
                        .fade(duration: 400.ms)
                        .slideY(begin: 0.3),
                    const SizedBox(height: 4),
                    Text('Find your dream job today',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        )).animate().fade(delay: 100.ms),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.jobSearch),
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color:
                              isDark ? AppColors.darkCard : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2))
                                ],
                        ),
                        child: Row(children: [
                          Icon(Icons.search_rounded,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary),
                          const SizedBox(width: 12),
                          Text('Search jobs, companies...',
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.tune_rounded,
                                color: AppColors.primary, size: 18),
                          ),
                        ]),
                      ),
                    ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),

            // Categories
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Browse Categories',
                        style: AppTextStyles.headlineSmall),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 104,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      scrollDirection: Axis.horizontal,
                      itemCount: _kCategories.length,
                      itemBuilder: (_, i) => _CategoryCard(
                        icon: _kCategories[i]['icon'] as IconData,
                        label: _kCategories[i]['label'] as String,
                        color: _kCategories[i]['color'] as Color,
                        onTap: () => context.push(AppRoutes.jobSearch),
                      ).animate().fade(delay: (i * 40).ms),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),

            // Recommended jobs
            BlocBuilder<JobsBloc, JobsState>(builder: (_, state) {
              if (state.recommendedJobs.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(children: [
                        Text('Recommended for You',
                            style: AppTextStyles.headlineSmall),
                        const Spacer(),
                        TextButton(
                            onPressed: () =>
                                context.push(AppRoutes.jobSearch),
                            child: const Text('See all')),
                      ]),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 224,
                      child: state.isLoading
                          ? ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              scrollDirection: Axis.horizontal,
                              itemCount: 3,
                              itemBuilder: (_, __) => Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: SkeletonLoader(
                                    width: 280,
                                    height: 200,
                                    borderRadius: 20),
                              ))
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              scrollDirection: Axis.horizontal,
                              itemCount: state.recommendedJobs.length,
                              itemBuilder: (_, i) => _FeaturedCard(
                                  job: state.recommendedJobs[i],
                                  onTap: () => context.push(
                                      '/student/jobs/${state.recommendedJobs[i].id}')),
                            ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              );
            }),

            // Recent jobs header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  Text('Recent Jobs', style: AppTextStyles.headlineSmall),
                  const Spacer(),
                  TextButton(
                      onPressed: () => context.push(AppRoutes.jobSearch),
                      child: const Text('See all')),
                ]),
              ),
            ),

            // Recent jobs list
            BlocBuilder<JobsBloc, JobsState>(builder: (context, state) {
              if (state.isLoading) {
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: JobCardSkeleton()),
                      childCount: 4,
                    ),
                  ),
                );
              }
              if (state.error != null) {
                return SliverToBoxAdapter(
                    child: ErrorView(
                        message: state.error!, onRetry: _loadData));
              }
              if (state.jobs.isEmpty) {
                return SliverToBoxAdapter(
                  child: EmptyState(
                    icon: Icons.work_off_outlined,
                    title: 'No jobs yet',
                    subtitle: 'Check back later for new listings',
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final job = state.jobs[i];
                      return BlocBuilder<SavedJobsCubit, SavedJobsState>(
                        builder: (ctx2, saved) => JobCard(
                          job: job,
                          isSaved: saved.isSaved(job.id),
                          onTap: () =>
                              context.push('/student/jobs/${job.id}'),
                          onSaveToggle: () {
                            final a = context.read<AuthBloc>().state;
                            if (a is AuthAuthenticated) {
                              ctx2.read<SavedJobsCubit>().toggleSave(
                                  studentId: a.user.uid, job: job);
                            }
                          },
                        ).animate().fade(delay: (i * 50).ms).slideY(
                            begin: 0.1, duration: 300.ms),
                      );
                    },
                    childCount: state.jobs.length,
                  ),
                ),
              );
            }),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

// Data
const _kCategories = [
  {'icon': Icons.computer_rounded, 'label': 'Technology', 'color': AppColors.primary},
  {'icon': Icons.design_services_rounded, 'label': 'Design', 'color': AppColors.secondary},
  {'icon': Icons.attach_money_rounded, 'label': 'Finance', 'color': AppColors.warning},
  {'icon': Icons.health_and_safety_rounded, 'label': 'Healthcare', 'color': AppColors.accent},
  {'icon': Icons.school_rounded, 'label': 'Education', 'color': AppColors.info},
  {'icon': Icons.campaign_rounded, 'label': 'Marketing', 'color': Color(0xFFBD63FF)},
  {'icon': Icons.engineering_rounded, 'label': 'Engineering', 'color': Color(0xFF43A0FF)},
  {'icon': Icons.more_horiz_rounded, 'label': 'Other', 'color': AppColors.darkTextSecondary},
];

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _CategoryCard(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 82,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: AppTextStyles.caption
                    .copyWith(color: color, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onTap;
  const _FeaturedCard({required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: Text(
                    job.companyName.isNotEmpty ? job.companyName[0] : 'C',
                    style: AppTextStyles.headlineMedium
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(job.companyName,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis)),
              if (job.companyVerified)
                const Icon(Icons.verified_rounded,
                    size: 16, color: Colors.white70),
            ]),
            const SizedBox(height: 14),
            Text(job.title,
                style:
                    AppTextStyles.headlineSmall.copyWith(color: Colors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            if (job.location != null) ...[
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.location_on_outlined,
                    size: 13, color: Colors.white70),
                const SizedBox(width: 4),
                Text(job.location!,
                    style:
                        AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
              ]),
            ],
            const Spacer(),
            Row(children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(job.jobType,
                    style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              Text(job.salaryDisplay,
                  style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ]),
          ],
        ),
      ),
    );
  }
}
