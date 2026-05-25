import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:career_connect/core/theme/app_colors.dart';
import 'package:career_connect/core/theme/app_typography.dart';
import 'package:career_connect/core/utils/extensions.dart';
import 'package:career_connect/core/utils/validators.dart';
import 'package:career_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:career_connect/features/jobs/data/models/job_model.dart';
import 'package:career_connect/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:career_connect/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:career_connect/shared/widgets/app_button.dart';
import 'package:career_connect/shared/widgets/app_text_field.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});
  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _pageCtrl = PageController();
  int _currentPage = 0;
  bool _isSubmitting = false;

  // Page 1 — Basic info
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _reqCtrl = TextEditingController();
  final _formKey1 = GlobalKey<FormState>();

  // Page 2 — Details
  String _jobType = 'full-time';
  String _category = 'Technology';
  String _experienceLevel = 'Entry Level (0-1 yr)';
  final _locationCtrl = TextEditingController();
  bool _remote = false;
  final _salaryMinCtrl = TextEditingController();
  final _salaryMaxCtrl = TextEditingController();
  DateTime _deadline = DateTime.now().add(const Duration(days: 30));

  // Page 3 — Skills
  final List<String> _skills = [];
  final _skillCtrl = TextEditingController();

  static const _jobTypes = ['full-time', 'part-time', 'internship', 'contract', 'remote'];
  static const _categories = [
    'Technology', 'Design', 'Finance', 'Healthcare',
    'Education', 'Marketing', 'Engineering', 'Other'
  ];
  static const _levels = [
    'Entry Level (0-1 yr)', 'Junior (1-3 yrs)',
    'Mid-Level (3-5 yrs)', 'Senior (5+ yrs)'
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _reqCtrl.dispose();
    _locationCtrl.dispose();
    _salaryMinCtrl.dispose();
    _salaryMaxCtrl.dispose();
    _skillCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage == 0 && !_formKey1.currentState!.validate()) return;
    if (_currentPage < 2) {
      _pageCtrl.nextPage(
          duration: 300.ms, curve: Curves.easeInOut);
      setState(() => _currentPage++);
    } else {
      _submit();
    }
  }

  void _prev() {
    if (_currentPage > 0) {
      _pageCtrl.previousPage(duration: 300.ms, curve: Curves.easeInOut);
      setState(() => _currentPage--);
    }
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final auth = context.read<AuthBloc>().state;
    final profile = context.read<ProfileCubit>().state;
    if (auth is! AuthAuthenticated) {
      setState(() => _isSubmitting = false);
      return;
    }

    final newJob = JobModel(
      id: const Uuid().v4(),
      employerId: auth.user.uid,
      companyName: profile.employer?.companyName ?? auth.user.name,
      companyLogoUrl: profile.employer?.logoUrl,
      companyVerified: profile.employer?.verified ?? false,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      requirements: _reqCtrl.text.trim().isEmpty ? null : _reqCtrl.text.trim(),
      location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      jobType: _jobType,
      category: _category,
      experienceLevel: _experienceLevel,
      salaryMin: double.tryParse(_salaryMinCtrl.text.trim()),
      salaryMax: double.tryParse(_salaryMaxCtrl.text.trim()),
      remote: _remote,
      skills: _skills,
      deadline: _deadline,
      status: 'active',
      applicantCount: 0,
      createdAt: DateTime.now(),
    );

    // Dispatch to JobsBloc which calls the CreateJob use-case.
    context.read<JobsBloc>().add(JobsCreateJob(newJob));
    await Future.delayed(800.ms);
    if (mounted) {
      setState(() => _isSubmitting = false);
      context.showSnackBar('Job posted successfully! 🎉');
      context.pop();
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
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text('Post a Job', style: AppTextStyles.headlineMedium),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / 3,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                color: AppColors.primary,
                minHeight: 4,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Step indicators
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: List.generate(3, (i) {
                final labels = ['Basic Info', 'Details', 'Skills'];
                final active = i <= _currentPage;
                return Expanded(
                  child: Row(children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: active ? AppColors.primary : AppColors.primary.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('${i + 1}',
                            style: TextStyle(
                                color: active ? Colors.white : AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(labels[i],
                        style: AppTextStyles.caption.copyWith(
                            color: active ? AppColors.primary : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
                    if (i < 2) ...[
                      const SizedBox(width: 6),
                      Expanded(child: Container(height: 1, color: AppColors.primary.withOpacity(0.2))),
                    ],
                  ]),
                );
              }),
            ),
          ).animate().fade(duration: 300.ms),

          // Pages
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _Page1(formKey: _formKey1, titleCtrl: _titleCtrl, descCtrl: _descCtrl, reqCtrl: _reqCtrl),
                _Page2(
                  jobType: _jobType, category: _category, experienceLevel: _experienceLevel,
                  locationCtrl: _locationCtrl, remote: _remote,
                  salaryMinCtrl: _salaryMinCtrl, salaryMaxCtrl: _salaryMaxCtrl,
                  deadline: _deadline,
                  jobTypes: _jobTypes, categories: _categories, levels: _levels,
                  onJobTypeChanged: (v) => setState(() => _jobType = v),
                  onCategoryChanged: (v) => setState(() => _category = v),
                  onLevelChanged: (v) => setState(() => _experienceLevel = v),
                  onRemoteChanged: (v) => setState(() => _remote = v),
                  onDeadlineChanged: (d) => setState(() => _deadline = d),
                ),
                _Page3(skills: _skills, skillCtrl: _skillCtrl, onAdd: (s) => setState(() { if (!_skills.contains(s)) _skills.add(s); }), onRemove: (s) => setState(() => _skills.remove(s))),
              ],
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              if (_currentPage > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _prev,
                    child: const Text('Back'),
                  ),
                ),
              if (_currentPage > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: AppButton(
                  label: _currentPage == 2 ? 'Post Job 🚀' : 'Continue',
                  isLoading: _isSubmitting,
                  onPressed: _next,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _Page1 extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleCtrl, descCtrl, reqCtrl;
  const _Page1({required this.formKey, required this.titleCtrl, required this.descCtrl, required this.reqCtrl});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Job Basics', style: AppTextStyles.headlineLarge).animate().fade(duration: 300.ms),
            const SizedBox(height: 4),
            Text('Tell candidates what the role is about',
                style: AppTextStyles.bodySmall.copyWith(color: context.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
            const SizedBox(height: 24),
            AppTextField(label: 'Job Title *', controller: titleCtrl, validator: AppValidators.required, hint: 'e.g. Flutter Developer', prefixIcon: const Icon(Icons.work_outline_rounded)),
            const SizedBox(height: 16),
            AppTextField(label: 'Job Description *', controller: descCtrl, validator: AppValidators.required, maxLines: 6, hint: 'Describe the role, responsibilities, and what the candidate will be doing...'),
            const SizedBox(height: 16),
            AppTextField(label: 'Requirements', controller: reqCtrl, maxLines: 4, hint: 'List qualifications, experience, and skills required...'),
          ],
        ),
      ),
    );
  }
}

class _Page2 extends StatelessWidget {
  final String jobType, category, experienceLevel;
  final TextEditingController locationCtrl, salaryMinCtrl, salaryMaxCtrl;
  final bool remote;
  final DateTime deadline;
  final List<String> jobTypes, categories, levels;
  final void Function(String) onJobTypeChanged, onCategoryChanged, onLevelChanged;
  final void Function(bool) onRemoteChanged;
  final void Function(DateTime) onDeadlineChanged;

  const _Page2({
    required this.jobType, required this.category, required this.experienceLevel,
    required this.locationCtrl, required this.salaryMinCtrl, required this.salaryMaxCtrl,
    required this.remote, required this.deadline, required this.jobTypes,
    required this.categories, required this.levels,
    required this.onJobTypeChanged, required this.onCategoryChanged,
    required this.onLevelChanged, required this.onRemoteChanged,
    required this.onDeadlineChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Job Details', style: AppTextStyles.headlineLarge),
          const SizedBox(height: 20),
          _label('Job Type', context),
          Wrap(spacing: 8, runSpacing: 8, children: jobTypes.map((t) => _SelectChip(label: t, selected: jobType == t, onTap: () => onJobTypeChanged(t))).toList()),
          const SizedBox(height: 16),
          _label('Category', context),
          Wrap(spacing: 8, runSpacing: 8, children: categories.map((c) => _SelectChip(label: c, selected: category == c, onTap: () => onCategoryChanged(c))).toList()),
          const SizedBox(height: 16),
          _label('Experience Level', context),
          Wrap(spacing: 8, runSpacing: 8, children: levels.map((l) => _SelectChip(label: l, selected: experienceLevel == l, onTap: () => onLevelChanged(l))).toList()),
          const SizedBox(height: 16),
          AppTextField(label: 'Location', controller: locationCtrl, hint: 'City, Country', prefixIcon: const Icon(Icons.location_on_outlined)),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text('Remote position', style: AppTextStyles.bodyMedium),
            value: remote,
            activeColor: AppColors.primary,
            onChanged: onRemoteChanged,
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: AppTextField(label: 'Min Salary (\$)', controller: salaryMinCtrl, keyboardType: TextInputType.number, hint: '50000')),
            const SizedBox(width: 12),
            Expanded(child: AppTextField(label: 'Max Salary (\$)', controller: salaryMaxCtrl, keyboardType: TextInputType.number, hint: '80000')),
          ]),
          const SizedBox(height: 16),
          _label('Application Deadline', context),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: deadline,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) onDeadlineChanged(picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Row(children: [
                const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                Text(deadline.toFormattedDate(), style: AppTextStyles.bodyMedium),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text, BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
  );
}

class _Page3 extends StatelessWidget {
  final List<String> skills;
  final TextEditingController skillCtrl;
  final void Function(String) onAdd;
  final void Function(String) onRemove;
  const _Page3({required this.skills, required this.skillCtrl, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Required Skills', style: AppTextStyles.headlineLarge),
          const SizedBox(height: 4),
          Text('Add skills candidates should have', style: AppTextStyles.bodySmall.copyWith(color: context.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: AppTextField(label: 'Add skill', controller: skillCtrl, hint: 'e.g. Flutter, Python...', textInputAction: TextInputAction.done, onSubmitted: (_) { onAdd(skillCtrl.text.trim()); skillCtrl.clear(); })),
            const SizedBox(width: 10),
            IconButton(
              icon: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.add_rounded, color: Colors.white, size: 20)),
              onPressed: () { onAdd(skillCtrl.text.trim()); skillCtrl.clear(); },
            ),
          ]),
          const SizedBox(height: 20),
          if (skills.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.15), style: BorderStyle.solid),
              ),
              child: Center(child: Text('Add skills above to get started', style: AppTextStyles.bodySmall.copyWith(color: context.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary))),
            )
          else
            Wrap(spacing: 8, runSpacing: 8, children: skills.map((s) => Chip(label: Text(s, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)), deleteIcon: const Icon(Icons.close_rounded, size: 14, color: AppColors.primary), onDeleted: () => onRemove(s), backgroundColor: AppColors.primary.withOpacity(0.1), side: BorderSide(color: AppColors.primary.withOpacity(0.25)))).toList()),
        ],
      ),
    );
  }
}

class _SelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SelectChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.primary.withOpacity(0.2)),
        ),
        child: Text(label, style: AppTextStyles.labelSmall.copyWith(color: selected ? Colors.white : AppColors.primary, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
