import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:career_connect/core/router/app_router.dart';
import 'package:career_connect/core/theme/app_colors.dart';
import 'package:career_connect/core/theme/app_typography.dart';
import 'package:career_connect/core/utils/extensions.dart';
import 'package:career_connect/core/utils/validators.dart';
import 'package:career_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:career_connect/shared/widgets/app_button.dart';
import 'package:career_connect/shared/widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _studentFormKey = GlobalKey<FormState>();
  final _employerFormKey = GlobalKey<FormState>();

  // Student fields
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // Employer fields
  final _empNameCtrl = TextEditingController();
  final _empEmailCtrl = TextEditingController();
  final _empPassCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose(); _confirmCtrl.dispose();
    _empNameCtrl.dispose(); _empEmailCtrl.dispose(); _empPassCtrl.dispose(); _companyCtrl.dispose();
    super.dispose();
  }

  void _registerStudent() {
    if (_studentFormKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthRegisterStudent(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      ));
    }
  }

  void _registerEmployer() {
    if (_employerFormKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthRegisterEmployer(
        name: _empNameCtrl.text.trim(),
        email: _empEmailCtrl.text.trim(),
        password: _empPassCtrl.text,
        companyName: _companyCtrl.text.trim(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthRegistrationSuccess) {
          context.showSnackBar('Account created! Please verify your email.');
          final route = state.role == 'employer' ? AppRoutes.employerHome : AppRoutes.studentHome;
          context.go(route);
        } else if (state is AuthError) {
          context.showSnackBar(state.message, isError: true);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Create Account', style: AppTextStyles.displaySmall)
                        .animate().fade().slideY(begin: 0.2),
                    const SizedBox(height: 8),
                    Text('Join CareerConnect as a student or employer',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        )).animate().fade(delay: 100.ms),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightBorder,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.white,
                        unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        labelStyle: AppTextStyles.labelLarge,
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(text: '🎓 Student'),
                          Tab(text: '🏢 Employer'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_StudentForm(formKey: _studentFormKey, nameCtrl: _nameCtrl, emailCtrl: _emailCtrl, passCtrl: _passCtrl, confirmCtrl: _confirmCtrl, onSubmit: _registerStudent),
                    _EmployerForm(formKey: _employerFormKey, nameCtrl: _empNameCtrl, emailCtrl: _empEmailCtrl, passCtrl: _empPassCtrl, companyCtrl: _companyCtrl, onSubmit: _registerEmployer)],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ', style: AppTextStyles.bodyMedium),
                    TextButton(onPressed: () => context.go(AppRoutes.login), child: const Text('Sign In')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl, emailCtrl, passCtrl, confirmCtrl;
  final VoidCallback onSubmit;
  const _StudentForm({required this.formKey, required this.nameCtrl, required this.emailCtrl, required this.passCtrl, required this.confirmCtrl, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(children: [
          const SizedBox(height: 8),
          AppTextField(label: 'Full Name', controller: nameCtrl, validator: AppValidators.name, prefixIcon: const Icon(Icons.person_outlined)),
          const SizedBox(height: 16),
          AppTextField(label: 'University Email', controller: emailCtrl, validator: AppValidators.email, keyboardType: TextInputType.emailAddress, prefixIcon: const Icon(Icons.email_outlined)),
          const SizedBox(height: 16),
          AppTextField(label: 'Password', controller: passCtrl, validator: AppValidators.password, obscureText: true, prefixIcon: const Icon(Icons.lock_outlined)),
          const SizedBox(height: 16),
          AppTextField(label: 'Confirm Password', controller: confirmCtrl, validator: (v) => AppValidators.confirmPassword(v, passCtrl.text), obscureText: true, prefixIcon: const Icon(Icons.lock_outlined), textInputAction: TextInputAction.done),
          const SizedBox(height: 28),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) => AppButton(label: 'Create Student Account', isLoading: state is AuthLoading, onPressed: onSubmit),
          ),
        ]),
      ),
    );
  }
}

class _EmployerForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl, emailCtrl, passCtrl, companyCtrl;
  final VoidCallback onSubmit;
  const _EmployerForm({required this.formKey, required this.nameCtrl, required this.emailCtrl, required this.passCtrl, required this.companyCtrl, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(children: [
          const SizedBox(height: 8),
          AppTextField(label: 'Your Full Name', controller: nameCtrl, validator: AppValidators.name, prefixIcon: const Icon(Icons.person_outlined)),
          const SizedBox(height: 16),
          AppTextField(label: 'Company Name', controller: companyCtrl, validator: (v) => AppValidators.required(v, fieldName: 'Company name'), prefixIcon: const Icon(Icons.business_outlined)),
          const SizedBox(height: 16),
          AppTextField(label: 'Work Email', controller: emailCtrl, validator: AppValidators.email, keyboardType: TextInputType.emailAddress, prefixIcon: const Icon(Icons.email_outlined)),
          const SizedBox(height: 16),
          AppTextField(label: 'Password', controller: passCtrl, validator: AppValidators.password, obscureText: true, prefixIcon: const Icon(Icons.lock_outlined), textInputAction: TextInputAction.done),
          const SizedBox(height: 28),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) => AppButton(label: 'Create Employer Account', isLoading: state is AuthLoading, onPressed: onSubmit),
          ),
        ]),
      ),
    );
  }
}
