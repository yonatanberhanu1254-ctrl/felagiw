import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:career_connect/core/config/app_config.dart';
import 'package:career_connect/core/router/app_router.dart';
import 'package:career_connect/core/theme/app_colors.dart';
import 'package:career_connect/core/theme/app_typography.dart';
import 'package:career_connect/core/utils/extensions.dart';
import 'package:career_connect/core/utils/validators.dart';
import 'package:career_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:career_connect/shared/widgets/app_button.dart';
import 'package:career_connect/shared/widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthLoginWithEmail(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          final role = state.user.role;
          context.go(role == AppConfig.roleEmployer ? AppRoutes.employerHome : AppRoutes.studentHome);
        } else if (state is AuthError) {
          context.showSnackBar(state.message, isError: true);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Header
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.work_rounded, color: Colors.white, size: 30),
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 24),
                  Text('Welcome back 👋', style: AppTextStyles.displaySmall)
                      .animate().fade(delay: 100.ms).slideY(begin: 0.2),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue your career journey',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ).animate().fade(delay: 200.ms),
                  const SizedBox(height: 40),
                  // Fields
                  AppTextField(
                    label: 'Email address',
                    hint: 'you@university.edu',
                    controller: _emailCtrl,
                    validator: AppValidators.email,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                    textInputAction: TextInputAction.next,
                  ).animate().fade(delay: 300.ms).slideX(begin: -0.1),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Password',
                    controller: _passCtrl,
                    validator: (v) => v == null || v.isEmpty ? 'Password is required' : null,
                    obscureText: true,
                    prefixIcon: const Icon(Icons.lock_outlined),
                    textInputAction: TextInputAction.done,
                  ).animate().fade(delay: 400.ms).slideX(begin: -0.1),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push(AppRoutes.forgotPassword),
                      child: const Text('Forgot Password?'),
                    ),
                  ).animate().fade(delay: 450.ms),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) => AppButton(
                      label: 'Sign In',
                      isLoading: state is AuthLoading,
                      onPressed: _submit,
                    ),
                  ).animate().fade(delay: 500.ms).slideY(begin: 0.2),
                  const SizedBox(height: 20),
                  // Divider
                  Row(children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR', style: AppTextStyles.labelSmall.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                    ),
                    const Expanded(child: Divider()),
                  ]).animate().fade(delay: 600.ms),
                  const SizedBox(height: 20),
                  // Google sign-in
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) => AppButton(
                      label: 'Continue with Google',
                      outlined: true,
                      icon: Icons.g_mobiledata_rounded,
                      isLoading: false,
                      onPressed: () => context.read<AuthBloc>().add(const AuthGoogleSignIn()),
                    ),
                  ).animate().fade(delay: 650.ms),
                  const SizedBox(height: 40),
                  // Register link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ", style: AppTextStyles.bodyMedium),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.register),
                          child: const Text('Sign Up'),
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 700.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
