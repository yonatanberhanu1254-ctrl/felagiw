import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:career_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:career_connect/features/auth/presentation/pages/splash_screen.dart';
import 'package:career_connect/features/auth/presentation/pages/onboarding_screen.dart';
import 'package:career_connect/features/auth/presentation/pages/login_screen.dart';
import 'package:career_connect/features/auth/presentation/pages/register_screen.dart';
import 'package:career_connect/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:career_connect/features/jobs/presentation/pages/student_home_screen.dart';
import 'package:career_connect/features/jobs/presentation/pages/job_search_screen.dart';
import 'package:career_connect/features/jobs/presentation/pages/job_detail_screen.dart';
import 'package:career_connect/features/saved_jobs/presentation/pages/saved_jobs_screen.dart';
import 'package:career_connect/features/applications/presentation/pages/applications_screen.dart';
import 'package:career_connect/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:career_connect/features/chat/presentation/pages/chat_list_screen.dart';
import 'package:career_connect/features/chat/presentation/pages/chat_detail_screen.dart';
import 'package:career_connect/features/profile/presentation/pages/student_profile_screen.dart';
import 'package:career_connect/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:career_connect/features/employer/presentation/pages/employer_dashboard_screen.dart';
import 'package:career_connect/features/employer/presentation/pages/create_job_screen.dart';
import 'package:career_connect/features/employer/presentation/pages/manage_jobs_screen.dart';
import 'package:career_connect/features/employer/presentation/pages/applicants_list_screen.dart';
import 'package:career_connect/features/employer/presentation/pages/applicant_detail_screen.dart';
import 'package:career_connect/features/employer/presentation/pages/company_profile_screen.dart';
import 'package:career_connect/shared/widgets/student_shell.dart';
import 'package:career_connect/shared/widgets/employer_shell.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  // Student routes
  static const studentHome = '/student/home';
  static const jobSearch = '/student/search';
  static const jobDetail = '/student/jobs/:id';
  static const savedJobs = '/student/saved';
  static const applications = '/student/applications';
  static const notifications = '/student/notifications';
  static const chatList = '/student/chats';
  static const chatDetail = '/student/chats/:chatId';
  static const studentProfile = '/student/profile';
  static const editProfile = '/student/profile/edit';

  // Employer routes
  static const employerHome = '/employer/home';
  static const createJob = '/employer/jobs/create';
  static const editJob = '/employer/jobs/:id/edit';
  static const manageJobs = '/employer/jobs';
  static const applicantsList = '/employer/jobs/:id/applicants';
  static const applicantDetail = '/employer/applicants/:id';
  static const companyProfile = '/employer/profile';
}

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.onboarding ||
          state.matchedLocation == AppRoutes.forgotPassword ||
          state.matchedLocation == AppRoutes.splash;

      if (authState is AuthUnauthenticated && !isAuthRoute) {
        return AppRoutes.login;
      }
      return null;
    },
    refreshListenable: _AuthBlocListenable(authBloc),
    routes: [
      // Auth routes
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.onboarding, builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: AppRoutes.register, builder: (_, __) => const RegisterScreen()),
      GoRoute(path: AppRoutes.forgotPassword, builder: (_, __) => const ForgotPasswordScreen()),

      // Student shell with bottom nav
      ShellRoute(
        builder: (context, state, child) => StudentShell(child: child),
        routes: [
          GoRoute(path: AppRoutes.studentHome, builder: (_, __) => const StudentHomeScreen()),
          GoRoute(path: AppRoutes.savedJobs, builder: (_, __) => const SavedJobsScreen()),
          GoRoute(path: AppRoutes.applications, builder: (_, __) => const ApplicationsScreen()),
          GoRoute(path: AppRoutes.notifications, builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: AppRoutes.studentProfile, builder: (_, __) => const StudentProfileScreen()),
        ],
      ),

      // Student top-level routes (no bottom nav)
      GoRoute(path: AppRoutes.jobSearch, builder: (_, __) => const JobSearchScreen()),
      GoRoute(
        path: AppRoutes.jobDetail,
        builder: (_, state) => JobDetailScreen(jobId: state.pathParameters['id']!),
      ),
      GoRoute(path: AppRoutes.editProfile, builder: (_, __) => const EditProfileScreen()),
      GoRoute(path: AppRoutes.chatList, builder: (_, __) => const ChatListScreen()),
      GoRoute(
        path: AppRoutes.chatDetail,
        builder: (_, state) => ChatDetailScreen(chatId: state.pathParameters['chatId']!),
      ),

      // Employer shell with bottom nav
      ShellRoute(
        builder: (context, state, child) => EmployerShell(child: child),
        routes: [
          GoRoute(path: AppRoutes.employerHome, builder: (_, __) => const EmployerDashboardScreen()),
          GoRoute(path: AppRoutes.manageJobs, builder: (_, __) => const ManageJobsScreen()),
          GoRoute(path: AppRoutes.companyProfile, builder: (_, __) => const CompanyProfileScreen()),
        ],
      ),

      // Employer top-level routes
      GoRoute(path: AppRoutes.createJob, builder: (_, __) => const CreateJobScreen()),
      GoRoute(
        path: AppRoutes.applicantsList,
        builder: (_, state) => ApplicantsListScreen(jobId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.applicantDetail,
        builder: (_, state) => ApplicantDetailScreen(applicationId: state.pathParameters['id']!),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
}

class _AuthBlocListenable extends ChangeNotifier {
  final AuthBloc _bloc;
  _AuthBlocListenable(this._bloc) {
    _bloc.stream.listen((_) => notifyListeners());
  }
}
