import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:career_connect/core/router/app_router.dart';
import 'package:career_connect/core/theme/app_colors.dart';
import 'package:career_connect/core/theme/app_typography.dart';
import 'package:career_connect/shared/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = [
    _Slide(
      icon: Icons.search_rounded,
      gradient: [Color(0xFF6C63FF), Color(0xFF9B97FF)],
      title: 'Find Your Dream Job',
      subtitle: 'Browse thousands of job and internship opportunities tailored for university students.',
    ),
    _Slide(
      icon: Icons.send_rounded,
      gradient: [Color(0xFF00D4AA), Color(0xFF00F5C4)],
      title: 'Apply in One Tap',
      subtitle: 'Upload your CV once and apply to any job instantly. Track every application in real-time.',
    ),
    _Slide(
      icon: Icons.connect_without_contact_rounded,
      gradient: [Color(0xFFFF6B6B), Color(0xFFFF9B9B)],
      title: 'Connect with Employers',
      subtitle: 'Chat directly with recruiters, get notified on updates and land your career faster.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go(AppRoutes.login),
                child: Text('Skip', style: AppTextStyles.labelLarge.copyWith(color: AppColors.darkTextSecondary)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final slide = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: slide.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: slide.gradient[0].withOpacity(0.4), blurRadius: 40, spreadRadius: 5)],
                          ),
                          child: Icon(slide.icon, size: 64, color: Colors.white),
                        )
                            .animate(key: ValueKey('icon$i'))
                            .scale(duration: 600.ms, curve: Curves.elasticOut),
                        const SizedBox(height: 48),
                        Text(slide.title,
                            style: AppTextStyles.displaySmall.copyWith(color: Colors.white),
                            textAlign: TextAlign.center)
                            .animate(key: ValueKey('title$i'))
                            .fade(duration: 400.ms)
                            .slideY(begin: 0.3),
                        const SizedBox(height: 16),
                        Text(slide.subtitle,
                            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.darkTextSecondary),
                            textAlign: TextAlign.center)
                            .animate(key: ValueKey('sub$i'))
                            .fade(delay: 100.ms, duration: 400.ms),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            SmoothPageIndicator(
              controller: _controller,
              count: _slides.length,
              effect: ExpandingDotsEffect(
                activeDotColor: AppColors.primary,
                dotColor: AppColors.darkBorder,
                dotHeight: 8,
                dotWidth: 8,
                expansionFactor: 4,
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _page < _slides.length - 1
                  ? AppButton(
                      label: 'Next',
                      onPressed: () => _controller.nextPage(duration: 300.ms, curve: Curves.easeInOut),
                      icon: Icons.arrow_forward_rounded,
                    )
                  : Column(
                      children: [
                        AppButton(label: 'Get Started', onPressed: () => context.go(AppRoutes.register)),
                        const SizedBox(height: 12),
                        AppButton(
                          label: 'I already have an account',
                          outlined: true,
                          onPressed: () => context.go(AppRoutes.login),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _Slide {
  final IconData icon;
  final List<Color> gradient;
  final String title;
  final String subtitle;
  const _Slide({required this.icon, required this.gradient, required this.title, required this.subtitle});
}
