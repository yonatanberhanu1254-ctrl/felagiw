import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:career_connect/core/router/app_router.dart';
import 'package:career_connect/core/theme/app_colors.dart';
import 'package:career_connect/core/theme/app_typography.dart';
import 'package:career_connect/core/utils/extensions.dart';
import 'package:career_connect/features/auth/data/models/user_model.dart';
import 'package:career_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:career_connect/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:career_connect/shared/widgets/app_button.dart';
import 'package:career_connect/shared/widgets/app_widgets.dart';
import 'package:career_connect/shared/widgets/skeleton_loader.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});
  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      context.read<ProfileCubit>().loadStudentProfile(auth.user.uid);
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
        title: Text('My Profile', style: AppTextStyles.headlineLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push(AppRoutes.editProfile),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            color: AppColors.error,
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Sign Out'),
                  content:
                      const Text('Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<AuthBloc>().add(const AuthSignOut());
                        },
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.error),
                        child: const Text('Sign Out')),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const _ProfileSkeleton();
          }
          if (state.error != null) {
            return ErrorView(
              message: state.error!,
              onRetry: () {
                final auth = context.read<AuthBloc>().state;
                if (auth is AuthAuthenticated) {
                  context
                      .read<ProfileCubit>()
                      .loadStudentProfile(auth.user.uid);
                }
              },
            );
          }
          final user = state.student;
          if (user == null) return const SizedBox.shrink();
          return _ProfileContent(user: user, isDark: isDark);
        },
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final UserModel user;
  final bool isDark;
  const _ProfileContent({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final pct = user.completionPercentage;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero card
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
                BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8))
              ],
            ),
            child: Column(
              children: [
                ProfileAvatar(
                  name: user.name,
                  imageUrl: user.photoUrl,
                  radius: 40,
                ),
                const SizedBox(height: 14),
                Text(user.name,
                    style: AppTextStyles.headlineLarge
                        .copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Text(user.email,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: Colors.white70)),
                if (user.university != null) ...[
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.school_outlined,
                        size: 14, color: Colors.white70),
                    const SizedBox(width: 5),
                    Text(user.university!,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: Colors.white70)),
                  ]),
                ],
                const SizedBox(height: 18),
                // Completion
                Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Profile Completion',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: Colors.white70)),
                      Text('${(pct * 100).toInt()}%',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      color: AppColors.secondary,
                      minHeight: 6,
                    ),
                  ),
                ]),
              ],
            ),
          ).animate().fade(duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),

          const SizedBox(height: 24),

          // Links row
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            if (user.githubUrl != null)
              _LinkButton(
                  label: 'GitHub',
                  icon: Icons.code_rounded,
                  color: const Color(0xFF333333),
                  onTap: () => launchUrl(Uri.parse(user.githubUrl!))),
            if (user.linkedinUrl != null)
              _LinkButton(
                  label: 'LinkedIn',
                  icon: Icons.work_outline_rounded,
                  color: const Color(0xFF0077B5),
                  onTap: () => launchUrl(Uri.parse(user.linkedinUrl!))),
            if (user.resumeUrl != null)
              _LinkButton(
                  label: 'Resume',
                  icon: Icons.description_outlined,
                  color: AppColors.primary,
                  onTap: () => launchUrl(Uri.parse(user.resumeUrl!))),
          ]).animate().fade(delay: 150.ms),

          const SizedBox(height: 24),

          // Bio
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            _Section(title: 'About Me', child: Text(user.bio!,
                style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    height: 1.7))),
            const SizedBox(height: 20),
          ],

          // Info grid
          _Section(
            title: 'Information',
            child: Column(
              children: [
                _InfoRow(Icons.email_outlined, 'Email', user.email),
                if (user.phone != null)
                  _InfoRow(Icons.phone_outlined, 'Phone', user.phone!),
                if (user.department != null)
                  _InfoRow(Icons.book_outlined, 'Department', user.department!),
                if (user.location != null)
                  _InfoRow(Icons.location_on_outlined, 'Location', user.location!),
              ],
            ),
          ).animate().fade(delay: 250.ms),

          const SizedBox(height: 20),

          // Skills
          if (user.skills.isNotEmpty)
            _Section(
              title: 'Skills',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user.skills.map((s) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                  ),
                  child: Text(s,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                )).toList(),
              ),
            ).animate().fade(delay: 300.ms),

          const SizedBox(height: 24),

          AppButton(
            label: 'Edit Profile',
            outlined: true,
            icon: Icons.edit_outlined,
            onPressed: () => context.push(AppRoutes.editProfile),
          ).animate().fade(delay: 400.ms),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      width: double.infinity,
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
          Text(title, style: AppTextStyles.headlineSmall),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text('$label: ',
            style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary)),
        Expanded(
          child: Text(value,
              style: AppTextStyles.bodySmall
                  .copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      ]),
    );
  }
}

class _LinkButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _LinkButton(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: color, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: const [
        SkeletonLoader(height: 220, borderRadius: 24),
        SizedBox(height: 20),
        SkeletonLoader(height: 80, borderRadius: 16),
        SizedBox(height: 16),
        SkeletonLoader(height: 120, borderRadius: 16),
      ]),
    );
  }
}
