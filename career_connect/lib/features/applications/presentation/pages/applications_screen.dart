import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:career_connect/core/theme/app_colors.dart';
import 'package:career_connect/core/theme/app_typography.dart';
import 'package:career_connect/core/utils/extensions.dart';
import 'package:career_connect/core/utils/status_helper.dart';
import 'package:career_connect/features/applications/data/models/application_model.dart';
import 'package:career_connect/features/applications/presentation/bloc/applications_bloc.dart';
import 'package:career_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:career_connect/shared/widgets/app_widgets.dart';
import 'package:career_connect/shared/widgets/skeleton_loader.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});
  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _tabs = const ['All', 'Pending', 'Shortlisted', 'Accepted', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      context
          .read<ApplicationsBloc>()
          .add(LoadStudentApplications(auth.user.uid));
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  List<ApplicationModel> _filtered(
      List<ApplicationModel> all, String tab) {
    if (tab == 'All') return all;
    return all
        .where((a) => a.status.toLowerCase() == tab.toLowerCase())
        .toList();
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
        title: Text('My Applications', style: AppTextStyles.headlineLarge),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor:
              isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          labelStyle:
              AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
          tabAlignment: TabAlignment.start,
        ),
      ),
      body: BlocBuilder<ApplicationsBloc, ApplicationsState>(
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
            return ErrorView(
              message: state.error!,
              onRetry: () {
                final auth = context.read<AuthBloc>().state;
                if (auth is AuthAuthenticated) {
                  context
                      .read<ApplicationsBloc>()
                      .add(LoadStudentApplications(auth.user.uid));
                }
              },
            );
          }
          return TabBarView(
            controller: _tabCtrl,
            children: _tabs.map((tab) {
              final filtered = _filtered(state.applications, tab);
              if (filtered.isEmpty) {
                return EmptyState(
                  icon: Icons.inbox_outlined,
                  title: tab == 'All'
                      ? 'No applications yet'
                      : 'No $tab applications',
                  subtitle: tab == 'All'
                      ? 'Start applying to jobs and track your progress here'
                      : 'None of your applications are currently $tab',
                );
              }
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  final auth = context.read<AuthBloc>().state;
                  if (auth is AuthAuthenticated) {
                    context
                        .read<ApplicationsBloc>()
                        .add(LoadStudentApplications(auth.user.uid));
                  }
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) => _ApplicationCard(
                    app: filtered[i],
                    onTap: () =>
                        context.push('/student/jobs/${filtered[i].jobId}'),
                  ).animate().fade(delay: (i * 60).ms).slideY(begin: 0.1),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final ApplicationModel app;
  final VoidCallback onTap;
  const _ApplicationCard({required this.app, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final statusColor = StatusHelper.getStatusColor(app.status);
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
              // Company initial
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: Text(
                    app.companyName.isNotEmpty
                        ? app.companyName[0].toUpperCase()
                        : 'C',
                    style: AppTextStyles.headlineMedium
                        .copyWith(color: statusColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(app.jobTitle,
                        style: AppTextStyles.headlineSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(app.companyName,
                        style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              StatusChip(status: app.status),
            ]),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(children: [
              Icon(Icons.schedule_outlined,
                  size: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
              const SizedBox(width: 5),
              Text('Applied ${app.appliedAt.toTimeAgo()}',
                  style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary)),
              const Spacer(),
              if (app.updatedAt != null)
                Text('Updated ${app.updatedAt!.toTimeAgo()}',
                    style: AppTextStyles.caption.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary)),
            ]),
            // Status progress bar
            const SizedBox(height: 10),
            _StatusProgressBar(status: app.status),
          ],
        ),
      ),
    );
  }
}

class _StatusProgressBar extends StatelessWidget {
  final String status;
  const _StatusProgressBar({required this.status});

  static const _steps = ['pending', 'reviewed', 'shortlisted', 'accepted'];

  @override
  Widget build(BuildContext context) {
    if (status == 'rejected') {
      return Row(children: [
        const Icon(Icons.cancel_rounded, color: AppColors.error, size: 16),
        const SizedBox(width: 6),
        Text('Application rejected',
            style: AppTextStyles.caption
                .copyWith(color: AppColors.error, fontWeight: FontWeight.w600)),
      ]);
    }
    final currentIndex =
        _steps.indexOf(status.toLowerCase()).clamp(0, _steps.length - 1);
    return Row(
      children: List.generate(_steps.length, (i) {
        final active = i <= currentIndex;
        return Expanded(
          child: Row(children: [
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: active
                      ? StatusHelper.getStatusColor(status)
                      : AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (i < _steps.length - 1) const SizedBox(width: 3),
          ]),
        );
      }),
    );
  }
}
