import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:career_connect/core/theme/app_colors.dart';
import 'package:career_connect/core/theme/app_typography.dart';
import 'package:career_connect/core/utils/extensions.dart';
import 'package:career_connect/core/utils/validators.dart';
import 'package:career_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:career_connect/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:career_connect/shared/widgets/app_button.dart';
import 'package:career_connect/shared/widgets/app_text_field.dart';
import 'package:career_connect/shared/widgets/app_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _uniCtrl;
  late final TextEditingController _deptCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _githubCtrl;
  late final TextEditingController _linkedinCtrl;
  late final TextEditingController _portfolioCtrl;
  List<String> _skills = [];
  final _skillInputCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ProfileCubit>().state;
    final u = cubit.student;
    _nameCtrl = TextEditingController(text: u?.name ?? '');
    _phoneCtrl = TextEditingController(text: u?.phone ?? '');
    _uniCtrl = TextEditingController(text: u?.university ?? '');
    _deptCtrl = TextEditingController(text: u?.department ?? '');
    _bioCtrl = TextEditingController(text: u?.bio ?? '');
    _locationCtrl = TextEditingController(text: u?.location ?? '');
    _githubCtrl = TextEditingController(text: u?.githubUrl ?? '');
    _linkedinCtrl = TextEditingController(text: u?.linkedinUrl ?? '');
    _portfolioCtrl = TextEditingController(text: u?.portfolioUrl ?? '');
    _skills = List.from(u?.skills ?? []);
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _phoneCtrl, _uniCtrl, _deptCtrl, _bioCtrl,
      _locationCtrl, _githubCtrl, _linkedinCtrl, _portfolioCtrl, _skillInputCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    final updated = auth.user.copyWith(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      university: _uniCtrl.text.trim().isEmpty ? null : _uniCtrl.text.trim(),
      department: _deptCtrl.text.trim().isEmpty ? null : _deptCtrl.text.trim(),
      bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
      location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      githubUrl: _githubCtrl.text.trim().isEmpty ? null : _githubCtrl.text.trim(),
      linkedinUrl: _linkedinCtrl.text.trim().isEmpty ? null : _linkedinCtrl.text.trim(),
      portfolioUrl: _portfolioCtrl.text.trim().isEmpty ? null : _portfolioCtrl.text.trim(),
      skills: _skills,
    );
    context.read<ProfileCubit>().updateStudentProfile(updated);
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      context.read<ProfileCubit>().uploadProfileImage(
          uid: auth.user.uid, imageFile: File(picked.path));
    }
  }

  Future<void> _pickResume() async {
    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx']);
    if (result == null || result.files.single.path == null) return;
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      context.read<ProfileCubit>().uploadResume(
          uid: auth.user.uid,
          resumeFile: File(result.files.single.path!));
    }
  }

  void _addSkill() {
    final s = _skillInputCtrl.text.trim();
    if (s.isNotEmpty && !_skills.contains(s)) {
      setState(() => _skills.add(s));
      _skillInputCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          context.showSnackBar(state.successMessage!);
          if (state.successMessage == 'Profile updated!') context.pop();
        }
        if (state.error != null) {
          context.showSnackBar(state.error!, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.pop(),
          ),
          title: Text('Edit Profile', style: AppTextStyles.headlineMedium),
          actions: [
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (_, s) => TextButton(
                onPressed: s.isSaving ? null : _save,
                child: s.isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                    : const Text('Save',
                        style: TextStyle(
                            color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Center(
                  child: BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (_, s) => Stack(
                      children: [
                        ProfileAvatar(
                          name: _nameCtrl.text.isEmpty ? 'U' : _nameCtrl.text,
                          imageUrl: s.student?.photoUrl,
                          radius: 44,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickPhoto,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle),
                              child: s.isSaving
                                  ? const Padding(
                                      padding: EdgeInsets.all(6),
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.camera_alt_rounded,
                                      color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fade(duration: 400.ms),
                const SizedBox(height: 28),

                _sectionTitle('Personal Info'),
                AppTextField(
                  label: 'Full Name',
                  controller: _nameCtrl,
                  validator: AppValidators.required,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Phone',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Location',
                  controller: _locationCtrl,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Bio',
                  controller: _bioCtrl,
                  maxLines: 4,
                  hint: 'Tell employers about yourself...',
                ),
                const SizedBox(height: 24),

                _sectionTitle('Education'),
                AppTextField(
                  label: 'University',
                  controller: _uniCtrl,
                  prefixIcon: const Icon(Icons.school_outlined),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Department / Major',
                  controller: _deptCtrl,
                  prefixIcon: const Icon(Icons.book_outlined),
                ),
                const SizedBox(height: 24),

                _sectionTitle('Links'),
                AppTextField(
                  label: 'GitHub URL',
                  controller: _githubCtrl,
                  keyboardType: TextInputType.url,
                  prefixIcon: const Icon(Icons.code_rounded),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'LinkedIn URL',
                  controller: _linkedinCtrl,
                  keyboardType: TextInputType.url,
                  prefixIcon: const Icon(Icons.work_outline_rounded),
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Portfolio URL',
                  controller: _portfolioCtrl,
                  keyboardType: TextInputType.url,
                  prefixIcon: const Icon(Icons.language_rounded),
                ),
                const SizedBox(height: 24),

                _sectionTitle('Skills'),
                Row(children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Add a skill',
                      controller: _skillInputCtrl,
                      hint: 'e.g. Flutter, Python...',
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addSkill(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.add_rounded,
                          color: Colors.white, size: 20),
                    ),
                    onPressed: _addSkill,
                  ),
                ]),
                if (_skills.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _skills
                        .map((s) => Chip(
                              label: Text(s, style: AppTextStyles.bodySmall),
                              deleteIcon: const Icon(Icons.close_rounded, size: 14),
                              onDeleted: () =>
                                  setState(() => _skills.remove(s)),
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              side: BorderSide(color: AppColors.primary.withOpacity(0.25)),
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 24),

                _sectionTitle('Resume'),
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (_, s) => AppButton(
                    label: s.student?.resumeUrl != null
                        ? 'Replace Resume (PDF)'
                        : 'Upload Resume (PDF)',
                    outlined: true,
                    icon: Icons.upload_file_rounded,
                    isLoading: s.isSaving,
                    onPressed: _pickResume,
                  ),
                ),
                if (context.read<ProfileCubit>().state.student?.resumeUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.success, size: 16),
                      const SizedBox(width: 6),
                      Text('Resume uploaded',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.success)),
                    ]),
                  ),

                const SizedBox(height: 40),
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (_, s) => AppButton(
                    label: 'Save Changes',
                    isLoading: s.isSaving,
                    onPressed: _save,
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text, style: AppTextStyles.headlineSmall),
      );
}
