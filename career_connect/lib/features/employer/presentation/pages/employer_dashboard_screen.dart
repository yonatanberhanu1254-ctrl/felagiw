import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:career_connect/core/router/app_router.dart';
import 'package:career_connect/core/theme/app_colors.dart';
import 'package:career_connect/core/theme/app_typography.dart';
import 'package:career_connect/core/utils/extensions.dart';
import 'package:career_connect/features/applications/presentation/bloc/applications_bloc.dart';
import 'package:career_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:career_connect/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:career_connect/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:career_connect/shared/widgets/app_widgets.dart';
import 'package:career_connect/shared/widgets/skeleton_loader.dart';

class EmployerDashboardScreen extends StatefulWidget {
  const EmployerDashboardScreen({super.key});
  @override
  State<EmployerDashboardScreen> createState() =>
      _EmployerDashboardScreenState();
}

class _EmployerDashboardScreenState extends State<EmployerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      context.read<ProfileCubit>().loadEmployerProfile(auth.user.uid);
      context
          .read<JobsBloc>()
          .add(JobsLoadHome(skills: const [], userId: auth.user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final auth = context.watch<AuthBloc>().state;
    final name = auth is AuthAuthenticated
        ? auth.user.name.split(' ').first
        : 'there';

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
                  child: const Icon(Icons.business_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Text('Dashboard',
                    style: AppTextStyles.headlineMedium
                        .copyWith(color: AppColors.primary)),
              ]),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (_, s) => ProfileAvatar(
                    name: name,
                    imageUrl: s.employer?.logoUrl,
                    radius: 16,
                    onTap: () => context.push(AppRoutes.companyProfile),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),

            // Greeting
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back, $name 👋',
                        style: AppTextStyles.displaySmall)
                        .animate()
                        .fade(duration: 400.ms)
                        .slideY(begin: 0.3),
                    const SizedBox(height: 4),
                    BlocBuilder<ProfileCubit, ProfileState>(
                      builder: (_, s) => Text(
                        s.employer?.companyName ?? 'Your Company',
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary),
                      ),
                    ).animate().fade(delay: 100.ms),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Stats row
            SliverToBoxAdapter(
              child: BlocBuilder<JobsBloc, JobsState>(
                builder: (_, jobState) =>
                    BlocBuilder<ApplicationsBloc, ApplicationsState>(
                  builder: (_, appState) {
                    if (jobState.isLoading) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(children: const [
                          Expanded(child: SkeletonLoader(height: 100)),
                          SizedBox(width: 12),
                          Expanded(child: SkeletonLoader(height: 100)),
                          SizedBox(width: 12),
                          Expanded(child: SkeletonLoader(height: 100)),
                        ]),
                      );
                    }
                    final activeJobs =
                        jobState.jobs.where((j) => j.status == 'active').length;
                    final totalApps = appState.applications.length;
                    final pending = appState.applications
                        .where((a) => a.status == 'pending')
                        .length;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                              child: _StatCard(
                                  label: 'Active Jobs',
                                  value: '$activeJobs',
                                  icon: Icons.work_outline_rounded,
                                  color: AppColors.primary)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _StatCard(
                                  label: 'Total Apps',
                                  value: '$totalApps',
                                  icon: Icons.description_outlined,
                                  color: AppColors.secondary)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _StatCard(
                                  label: 'Pending',
                                  value: '$pending',
                                  icon: Icons.schedule_rounded,
                                  color: AppColors.warning)),
                        ],
                      ).animate().fade(delay: 200.ms),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // Quick actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quick Actions', style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.add_circle_outline_rounded,
                          label: 'Post a Job',
                          color: AppColors.primary,
                          onTap: () => context.push(AppRoutes.createJob),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.list_alt_rounded,
                          label: 'Manage Jobs',
                          color: AppColors.secondary,
                          onTap: () => context.push(AppRoutes.manageJobs),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.business_outlined,
                          label: 'Company Profile',
                          color: AppColors.warning,
                          onTap: () => context.push(AppRoutes.companyProfile),
                        ),
                      ),
                    ]).animate().fade(delay: 300.ms),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // Recent activity
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Recent Applications',
                    style: AppTextStyles.headlineSmall),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            BlocBuilder<ApplicationsBloc, ApplicationsState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, __) => const Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: SkeletonLoader(height: 80)),
                        childCount: 4,
                      ),
                    ),
                  );
                }
                if (state.applications.isEmpty) {
                  return SliverToBoxAdapter(
                    child: EmptyState(
                      icon: Icons.inbox_outlined,
                      title: 'No applications yet',
                      subtitle:
                          'Post a job to start receiving applications',
                      actionLabel: 'Post a Job',
                      onAction: () => context.push(AppRoutes.createJob),
                    ),
                  );
                }
                final recent = state.applications.take(5).toList();
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _RecentAppTile(
                        app: recent[i],
                        onTap: () => context.push(
                            '/employer/applicants/${recent[i].id}'),
                      ).animate().fade(delay: (i * 60).ms),
                      childCount: recent.length,
                    ),
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      padding: const EdgeInsets.all(14),
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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: AppTextStyles.displaySmall
                  .copyWith(fontSize: 24, color: color)),
          Text(label,
              style: AppTextStyles.caption.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary)),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionCard(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(label,
              style: AppTextStyles.caption.copyWith(
                  color: color, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 2),
        ]),
      ),
    );
  }
}

class _RecentAppTile extends StatelessWidget {
  final dynamic app;
  final VoidCallback onTap;
  const _RecentAppTile({required this.app, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Row(children: [
          ProfileAvatar(name: app.studentName, imageUrl: app.studentPhotoUrl, radius: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(app.studentName,
                  style: AppTextStyles.bodySmall
                      .copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Text(app.jobTitle,
                  style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ]),
          ),
          StatusChip(status: app.status),
        ]),
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'accepted': return AppColors.success;
      case 'rejected': return AppColors.error;
      case 'shortlisted': return AppColors.primary;
      default: return AppColors.warning;
    }
  }
}
