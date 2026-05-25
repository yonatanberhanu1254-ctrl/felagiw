import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:career_connect/core/theme/app_colors.dart';
import 'package:career_connect/core/theme/app_typography.dart';
import 'package:career_connect/core/utils/extensions.dart';
import 'package:career_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:career_connect/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:career_connect/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:career_connect/features/saved_jobs/presentation/cubit/saved_jobs_cubit.dart';
import 'package:career_connect/shared/widgets/app_widgets.dart';
import 'package:career_connect/shared/widgets/job_card.dart';
import 'package:career_connect/shared/widgets/skeleton_loader.dart';

class JobSearchScreen extends StatefulWidget {
  const JobSearchScreen({super.key});
  @override
  State<JobSearchScreen> createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends State<JobSearchScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  JobFilters _filters = const JobFilters();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    context.read<JobsBloc>().add(const JobsRefresh());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 300) {
      context.read<JobsBloc>().add(const JobsLoadMore());
    }
  }

  void _applySearch(String query) {
    _filters = JobFilters(
      category: _filters.category,
      jobType: _filters.jobType,
      location: _filters.location,
      remote: _filters.remote,
      minSalary: _filters.minSalary,
      maxSalary: _filters.maxSalary,
      experienceLevel: _filters.experienceLevel,
      query: query.trim().isEmpty ? null : query.trim(),
    );
    context.read<JobsBloc>().add(JobsApplyFilters(_filters));
  }

  void _applyFilters(JobFilters f) {
    _filters = f;
    context.read<JobsBloc>().add(JobsApplyFilters(f));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text('Find Jobs', style: AppTextStyles.headlineMedium),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.tune_rounded : Icons.tune_outlined,
              color: _showFilters ? AppColors.primary : null,
            ),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => _applySearch(v),
              decoration: InputDecoration(
                hintText: 'Job title, skill, or company...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          _applySearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor:
                    isDark ? AppColors.darkCard : AppColors.lightCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ).animate().fade(duration: 300.ms).slideY(begin: -0.2),

          // Filter panel
          if (_showFilters)
            _FilterPanel(
              filters: _filters,
              onApply: (f) {
                _applyFilters(f);
                setState(() => _showFilters = false);
              },
              onClear: () {
                _applyFilters(const JobFilters());
                setState(() {
                  _showFilters = false;
                  _searchCtrl.clear();
                });
              },
            ).animate().fade(duration: 200.ms).slideY(begin: -0.1),

          // Results count
          BlocBuilder<JobsBloc, JobsState>(
            builder: (_, state) => Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(children: [
                Text(
                  state.isLoading
                      ? 'Searching...'
                      : '${state.jobs.length} jobs found',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const Spacer(),
                if (state.filters.hasFilters)
                  TextButton.icon(
                    onPressed: () {
                      context
                          .read<JobsBloc>()
                          .add(const JobsClearFilters());
                      _searchCtrl.clear();
                      _filters = const JobFilters();
                    },
                    icon: const Icon(Icons.clear_all_rounded, size: 16),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        visualDensity: VisualDensity.compact),
                  ),
              ]),
            ),
          ),

          // Job list
          Expanded(
            child: BlocBuilder<JobsBloc, JobsState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 6,
                    itemBuilder: (_, __) => const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: JobCardSkeleton()),
                  );
                }
                if (state.error != null) {
                  return ErrorView(
                      message: state.error!,
                      onRetry: () =>
                          context.read<JobsBloc>().add(const JobsRefresh()));
                }
                if (state.jobs.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No results found',
                    subtitle:
                        'Try different keywords or remove filters',
                    actionLabel: 'Clear Filters',
                    onAction: () =>
                        context.read<JobsBloc>().add(const JobsClearFilters()),
                  );
                }
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.jobs.length + (state.isPaginating ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i == state.jobs.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary)),
                      );
                    }
                    final job = state.jobs[i];
                    return BlocBuilder<SavedJobsCubit, SavedJobsState>(
                      builder: (ctx, saved) => JobCard(
                        job: job,
                        isSaved: saved.isSaved(job.id),
                        onTap: () =>
                            context.push('/student/jobs/${job.id}'),
                        onSaveToggle: () {
                          final a = context.read<AuthBloc>().state;
                          if (a is AuthAuthenticated) {
                            ctx.read<SavedJobsCubit>().toggleSave(
                                studentId: a.user.uid, job: job);
                          }
                        },
                      ).animate().fade(delay: (i * 30).ms),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter panel ─────────────────────────────────────────────────────────────

class _FilterPanel extends StatefulWidget {
  final JobFilters filters;
  final void Function(JobFilters) onApply;
  final VoidCallback onClear;
  const _FilterPanel(
      {required this.filters, required this.onApply, required this.onClear});
  @override
  State<_FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<_FilterPanel> {
  late String? _category;
  late String? _jobType;
  late bool _remote;
  late String? _experienceLevel;

  static const _jobTypes = [
    'full-time', 'part-time', 'internship', 'contract', 'remote'
  ];
  static const _categories = [
    'Technology', 'Design', 'Finance', 'Healthcare',
    'Education', 'Marketing', 'Engineering', 'Other'
  ];
  static const _levels = [
    'Entry Level (0-1 yr)', 'Junior (1-3 yrs)',
    'Mid-Level (3-5 yrs)', 'Senior (5+ yrs)'
  ];

  @override
  void initState() {
    super.initState();
    _category = widget.filters.category;
    _jobType = widget.filters.jobType;
    _remote = widget.filters.remote ?? false;
    _experienceLevel = widget.filters.experienceLevel;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filters', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 12),
          _label('Job Type'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _jobTypes
                .map((t) => _Chip(
                      label: t,
                      selected: _jobType == t,
                      onTap: () =>
                          setState(() => _jobType = _jobType == t ? null : t),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          _label('Category'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories
                .map((c) => _Chip(
                      label: c,
                      selected: _category == c,
                      onTap: () => setState(
                          () => _category = _category == c ? null : c),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          _label('Experience Level'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _levels
                .map((l) => _Chip(
                      label: l,
                      selected: _experienceLevel == l,
                      onTap: () => setState(() =>
                          _experienceLevel =
                              _experienceLevel == l ? null : l),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text('Remote only', style: AppTextStyles.bodyMedium),
            value: _remote,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _remote = v),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onClear,
                child: const Text('Clear All'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                style:
                    FilledButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () => widget.onApply(JobFilters(
                  category: _category,
                  jobType: _jobType,
                  remote: _remote,
                  experienceLevel: _experienceLevel,
                )),
                child: const Text('Apply'),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: AppTextStyles.labelSmall.copyWith(
                color: context.isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary)),
      );
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.2)),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: selected ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
