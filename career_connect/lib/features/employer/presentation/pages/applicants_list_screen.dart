import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:career_connect/core/theme/app_colors.dart';
import 'package:career_connect/core/theme/app_typography.dart';
import 'package:career_connect/core/utils/extensions.dart';
import 'package:career_connect/features/applications/data/models/application_model.dart';
import 'package:career_connect/features/applications/presentation/bloc/applications_bloc.dart';
import 'package:career_connect/shared/widgets/app_widgets.dart';
import 'package:career_connect/shared/widgets/skeleton_loader.dart';

class ApplicantsListScreen extends StatefulWidget {
  final String jobId;
  const ApplicantsListScreen({super.key, required this.jobId});
  @override
  State<ApplicantsListScreen> createState() => _ApplicantsListScreenState();
}

class _ApplicantsListScreenState extends State<ApplicantsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String _searchQuery = '';
  final _tabs = ['All', 'Pending', 'Shortlisted', 'Accepted', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    context.read<ApplicationsBloc>().add(LoadJobApplicants(widget.jobId));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  List<ApplicationModel> _filtered(List<ApplicationModel> all, String tab) {
    var list = tab == 'All' ? all : all.where((a) => a.status.toLowerCase() == tab.toLowerCase()).toList();
    if (_searchQuery.isNotEmpty) {
      list = list.where((a) =>
          a.studentName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.studentEmail.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return list;
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
        title: Text('Applicants', style: AppTextStyles.headlineMedium),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          labelStyle: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
          tabAlignment: TabAlignment.start,
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search applicants by name...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          // Summary chips
          BlocBuilder<ApplicationsBloc, ApplicationsState>(
            builder: (_, state) {
              if (state.applications.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(children: [
                  _SummaryChip(label: 'Total', count: state.applications.length, color: AppColors.primary),
                  const SizedBox(width: 8),
                  _SummaryChip(label: 'Pending', count: state.applications.where((a) => a.status == 'pending').length, color: AppColors.warning),
                  const SizedBox(width: 8),
                  _SummaryChip(label: 'Shortlisted', count: state.applications.where((a) => a.status == 'shortlisted').length, color: AppColors.primary),
                ]),
              );
            },
          ),
          // List
          Expanded(
            child: BlocBuilder<ApplicationsBloc, ApplicationsState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 5,
                    itemBuilder: (_, __) => const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: SkeletonLoader(height: 88)),
                  );
                }
                if (state.error != null) return ErrorView(message: state.error!);
                return TabBarView(
                  controller: _tabCtrl,
                  children: _tabs.map((tab) {
                    final list = _filtered(state.applications, tab);
                    if (list.isEmpty) {
                      return EmptyState(
                        icon: Icons.people_outline_rounded,
                        title: tab == 'All' ? 'No applicants yet' : 'No $tab applicants',
                        subtitle: tab == 'All'
                            ? 'Applicants will appear here once they apply'
                            : 'No applicants with $tab status',
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      itemCount: list.length,
                      itemBuilder: (ctx, i) => _ApplicantTile(
                        application: list[i],
                        onTap: () => context.push('/employer/applicants/${list[i].id}'),
                        onStatusChange: (status) {
                          ctx.read<ApplicationsBloc>().add(
                              UpdateApplicationStatusEvent(
                                  applicationId: list[i].id, status: status));
                        },
                      ).animate().fade(delay: (i * 50).ms).slideY(begin: 0.08),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _SummaryChip({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text('$label: $count',
          style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w700)),
    );
  }
}

class _ApplicantTile extends StatelessWidget {
  final ApplicationModel application;
  final VoidCallback onTap;
  final void Function(String) onStatusChange;
  const _ApplicantTile({required this.application, required this.onTap, required this.onStatusChange});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          boxShadow: isDark
              ? []
              : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          ProfileAvatar(name: application.studentName, imageUrl: application.studentPhotoUrl, radius: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(application.studentName,
                  style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(application.studentEmail,
                  style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text('Applied ${application.appliedAt.toTimeAgo()}',
                  style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
            ]),
          ),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            StatusChip(status: application.status),
            const SizedBox(height: 6),
            // Quick action buttons
            if (application.status == 'pending' || application.status == 'reviewed')
              Row(mainAxisSize: MainAxisSize.min, children: [
                _ActionBtn(
                  icon: Icons.star_rounded,
                  color: AppColors.primary,
                  tooltip: 'Shortlist',
                  onTap: () => onStatusChange('shortlisted'),
                ),
                const SizedBox(width: 4),
                _ActionBtn(
                  icon: Icons.check_circle_rounded,
                  color: AppColors.success,
                  tooltip: 'Accept',
                  onTap: () => onStatusChange('accepted'),
                ),
                const SizedBox(width: 4),
                _ActionBtn(
                  icon: Icons.cancel_rounded,
                  color: AppColors.error,
                  tooltip: 'Reject',
                  onTap: () => onStatusChange('rejected'),
                ),
              ]),
          ]),
        ]),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.color, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 16),
        ),
      ),
    );
  }
}
