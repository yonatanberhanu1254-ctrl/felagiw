import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:career_connect/core/config/app_config.dart';
import 'package:career_connect/core/router/app_router.dart';
import 'package:career_connect/core/theme/app_colors.dart';
import 'package:career_connect/core/theme/app_typography.dart';
import 'package:career_connect/features/auth/presentation/bloc/auth_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) context.read<AuthBloc>().add(const AuthCheckRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          final role = state.user.role;
          if (role == AppConfig.roleEmployer) {
            context.go(AppRoutes.employerHome);
          } else {
            context.go(AppRoutes.studentHome);
          }
        } else if (state is AuthUnauthenticated) {
          context.go(AppRoutes.onboarding);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.darkBg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.work_rounded, color: Colors.white, size: 50),
              )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .fade(duration: 400.ms),
              const SizedBox(height: 24),
              Text(
                AppConfig.appName,
                style: AppTextStyles.displayMedium.copyWith(color: Colors.white),
              ).animate().fade(delay: 300.ms, duration: 400.ms).slideY(begin: 0.3),
              const SizedBox(height: 8),
              Text(
                'Find your dream career',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkTextSecondary),
              ).animate().fade(delay: 500.ms, duration: 400.ms),
              const SizedBox(height: 60),
              const CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ).animate().fade(delay: 700.ms),
            ],
          ),
        ),
      ),
    );
  }
}
