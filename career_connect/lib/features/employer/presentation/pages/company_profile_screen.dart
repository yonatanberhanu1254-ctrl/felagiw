import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:career_connect/core/theme/app_colors.dart';
import 'package:career_connect/core/theme/app_typography.dart';
import 'package:career_connect/core/utils/extensions.dart';
import 'package:career_connect/core/utils/validators.dart';
import 'package:career_connect/features/auth/data/models/employer_model.dart';
import 'package:career_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:career_connect/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:career_connect/shared/widgets/app_button.dart';
import 'package:career_connect/shared/widgets/app_text_field.dart';
import 'package:career_connect/shared/widgets/app_widgets.dart';
import 'package:career_connect/shared/widgets/skeleton_loader.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});
  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _editing = false;

  // Form fields
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _companyNameCtrl;
  late TextEditingController _industryCtrl;
  late TextEditingController _websiteCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _phoneCtrl;

  static const _industries = [
    'Technology', 'Finance', 'Healthcare', 'Education',
    'Marketing', 'Engineering', 'Retail', 'Manufacturing', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      context.read<ProfileCubit>().loadEmployerProfile(auth.user.uid);
    }
    _initControllers(null);
  }

  void _initControllers(EmployerModel? emp) {
    _companyNameCtrl = TextEditingController(text: emp?.companyName ?? '');
    _industryCtrl = TextEditingController(text: emp?.industry ?? '');
    _websiteCtrl = TextEditingController(text: emp?.website ?? '');
    _descCtrl = TextEditingController(text: emp?.description ?? '');
    _locationCtrl = TextEditingController(text: emp?.location ?? '');
    _phoneCtrl = TextEditingController(text: emp?.phone ?? '');
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    for (final c in [_companyNameCtrl, _industryCtrl, _websiteCtrl, _descCtrl, _locationCtrl, _phoneCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final state = context.read<ProfileCubit>().state;
    final emp = state.employer;
    if (emp == null) return;
    final updated = emp.copyWith(
      companyName: _companyNameCtrl.text.trim(),
      industry: _industryCtrl.text.trim().isEmpty ? null : _industryCtrl.text.trim(),
      website: _websiteCtrl.text.trim().isEmpty ? null : _websiteCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
    );
    context.read<ProfileCubit>().updateEmployerProfile(updated);
  }

  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      context.read<ProfileCubit>().uploadCompanyLogo(uid: auth.user.uid, imageFile: File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          context.showSnackBar(state.successMessage!);
          setState(() => _editing = false);
        }
        if (state.error != null) {
          context.showSnackBar(state.error!, isError: true);
        }
        // Sync form when employer loads
        if (state.employer != null && !_editing) {
          _companyNameCtrl.text = state.employer!.companyName;
          _industryCtrl.text = state.employer!.industry ?? '';
          _websiteCtrl.text = state.employer!.website ?? '';
          _descCtrl.text = state.employer!.description ?? '';
          _locationCtrl.text = state.employer!.location ?? '';
          _phoneCtrl.text = state.employer!.phone ?? '';
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text('Company Profile', style: AppTextStyles.headlineLarge),
          actions: [
            if (!_editing)
              TextButton.icon(
                onPressed: () => setState(() => _editing = true),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              )
            else
              Row(children: [
                TextButton(
                    onPressed: () => setState(() => _editing = false),
                    child: const Text('Cancel')),
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (_, s) => TextButton(
                    onPressed: s.isSaving ? null : _save,
                    child: s.isSaving
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                        : const Text('Save',
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            context.read<AuthBloc>().add(const AuthSignOut());
                          },
                          style: TextButton.styleFrom(foregroundColor: AppColors.error),
                          child: const Text('Sign Out')),
                    ],
                  ),
                );
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabCtrl,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            tabs: const [Tab(text: 'Profile'), Tab(text: 'About')],
          ),
        ),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state.isLoading) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: const [
                  SkeletonLoader(height: 200, borderRadius: 24),
                  SizedBox(height: 16),
                  SkeletonLoader(height: 100, borderRadius: 16),
                  SizedBox(height: 12),
                  SkeletonLoader(height: 150, borderRadius: 16),
                ]),
              );
            }
            final emp = state.employer;
            if (emp == null) {
              return ErrorView(
                message: 'Company profile not found',
                onRetry: () {
                  final auth = context.read<AuthBloc>().state;
                  if (auth is AuthAuthenticated) {
                    context.read<ProfileCubit>().loadEmployerProfile(auth.user.uid);
                  }
                },
              );
            }
            return TabBarView(
              controller: _tabCtrl,
              children: [
                // ── Profile tab ───────────────────────────────────────────
                _editing
                    ? _EditView(
                        formKey: _formKey,
                        companyNameCtrl: _companyNameCtrl,
                        industryCtrl: _industryCtrl,
                        websiteCtrl: _websiteCtrl,
                        descCtrl: _descCtrl,
                        locationCtrl: _locationCtrl,
                        phoneCtrl: _phoneCtrl,
                        industries: _industries,
                        isSaving: state.isSaving,
                        onPickLogo: _pickLogo,
                        onSave: _save,
                        logoUrl: emp.logoUrl,
                        companyName: emp.companyName,
                      )
                    : _ProfileView(emp: emp, isDark: isDark, onEdit: () => setState(() => _editing = true)),
                // ── About tab ─────────────────────────────────────────────
                _AboutView(emp: emp, isDark: isDark),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  final EmployerModel emp;
  final bool isDark;
  final VoidCallback onEdit;
  const _ProfileView({required this.emp, required this.isDark, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))
              ],
            ),
            child: Column(children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: emp.logoUrl != null
                    ? ClipOval(child: Image.network(emp.logoUrl!, fit: BoxFit.cover))
                    : Center(
                        child: Text(
                          emp.companyName.isNotEmpty ? emp.companyName[0].toUpperCase() : 'C',
                          style: AppTextStyles.displaySmall.copyWith(color: Colors.white),
                        ),
                      ),
              ),
              const SizedBox(height: 14),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(emp.companyName, style: AppTextStyles.headlineLarge.copyWith(color: Colors.white)),
                if (emp.verified) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
                ],
              ]),
              if (emp.industry != null) ...[
                const SizedBox(height: 4),
                Text(emp.industry!, style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
              ],
              if (emp.location != null) ...[
                const SizedBox(height: 6),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.location_on_outlined, size: 13, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(emp.location!, style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                ]),
              ],
            ]),
          ).animate().fade(duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),

          const SizedBox(height: 20),

          // Info rows
          _InfoCard(isDark: isDark, title: 'Company Details', children: [
            if (emp.phone != null) _InfoRow(Icons.phone_outlined, 'Phone', emp.phone!),
            if (emp.website != null)
              _InfoRow(Icons.language_rounded, 'Website', emp.website!, onTap: () async {
                final uri = Uri.parse(emp.website!);
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              }),
            _InfoRow(Icons.work_outline_rounded, 'Jobs Posted', '${emp.totalJobsPosted}'),
            _InfoRow(Icons.calendar_today_outlined, 'Member Since', emp.createdAt.toFormattedDate()),
          ]).animate().fade(delay: 200.ms),

          const SizedBox(height: 20),

          AppButton(
            label: 'Edit Profile',
            outlined: true,
            icon: Icons.edit_outlined,
            onPressed: onEdit,
          ).animate().fade(delay: 300.ms),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _AboutView extends StatelessWidget {
  final EmployerModel emp;
  final bool isDark;
  const _AboutView({required this.emp, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (emp.description != null && emp.description!.isNotEmpty) ...[
            Text('About ${emp.companyName}', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 12),
            Text(emp.description!,
                style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    height: 1.7)),
          ] else
            EmptyState(
              icon: Icons.info_outline_rounded,
              title: 'No description yet',
              subtitle: 'Add a company description\nto attract more candidates',
            ),
        ],
      ),
    );
  }
}

class _EditView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController companyNameCtrl, industryCtrl, websiteCtrl, descCtrl, locationCtrl, phoneCtrl;
  final List<String> industries;
  final bool isSaving;
  final VoidCallback onPickLogo, onSave;
  final String? logoUrl;
  final String companyName;

  const _EditView({
    required this.formKey, required this.companyNameCtrl, required this.industryCtrl,
    required this.websiteCtrl, required this.descCtrl, required this.locationCtrl,
    required this.phoneCtrl, required this.industries, required this.isSaving,
    required this.onPickLogo, required this.onSave, this.logoUrl, required this.companyName,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo picker
            Center(
              child: Stack(children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                  ),
                  child: logoUrl != null
                      ? ClipOval(child: Image.network(logoUrl!, fit: BoxFit.cover))
                      : Center(child: Text(companyName.isNotEmpty ? companyName[0] : 'C',
                          style: AppTextStyles.displaySmall.copyWith(color: AppColors.primary))),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: GestureDetector(
                    onTap: onPickLogo,
                    child: Container(
                      width: 26, height: 26,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 24),
            AppTextField(label: 'Company Name *', controller: companyNameCtrl, validator: AppValidators.required, prefixIcon: const Icon(Icons.business_outlined)),
            const SizedBox(height: 12),
            AppTextField(label: 'Industry', controller: industryCtrl, hint: 'e.g. Technology', prefixIcon: const Icon(Icons.category_outlined)),
            const SizedBox(height: 12),
            AppTextField(label: 'Website', controller: websiteCtrl, keyboardType: TextInputType.url, prefixIcon: const Icon(Icons.language_rounded)),
            const SizedBox(height: 12),
            AppTextField(label: 'Phone', controller: phoneCtrl, keyboardType: TextInputType.phone, prefixIcon: const Icon(Icons.phone_outlined)),
            const SizedBox(height: 12),
            AppTextField(label: 'Location', controller: locationCtrl, prefixIcon: const Icon(Icons.location_on_outlined)),
            const SizedBox(height: 12),
            AppTextField(label: 'Company Description', controller: descCtrl, maxLines: 5, hint: 'Tell candidates about your company, culture, and mission...'),
            const SizedBox(height: 24),
            AppButton(label: 'Save Changes', isLoading: isSaving, onPressed: onSave),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool isDark;
  const _InfoCard({required this.title, required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: AppTextStyles.headlineSmall),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  const _InfoRow(this.icon, this.label, this.value, {this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Row(children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 10),
          Text('$label: ', style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
          Expanded(
            child: Text(value,
                style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: onTap != null ? AppColors.primary : null,
                    decoration: onTap != null ? TextDecoration.underline : null),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ]),
      ),
    );
  }
}
