import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:career_connect/core/di/injection.dart';
import 'package:career_connect/core/router/app_router.dart';
import 'package:career_connect/core/theme/app_theme.dart';
import 'package:career_connect/features/applications/presentation/bloc/applications_bloc.dart';
import 'package:career_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:career_connect/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:career_connect/features/employer/presentation/bloc/employer_bloc.dart';
import 'package:career_connect/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:career_connect/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:career_connect/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:career_connect/features/saved_jobs/presentation/cubit/saved_jobs_cubit.dart';
import 'package:career_connect/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Make the status bar transparent
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize service locator
  await initDependencies();

  runApp(const CareerConnectApp());
}

class CareerConnectApp extends StatefulWidget {
  const CareerConnectApp({super.key});

  @override
  State<CareerConnectApp> createState() => _CareerConnectAppState();
}

class _CareerConnectAppState extends State<CareerConnectApp> {
  // Hold a reference to the router so it isn't rebuilt on every setState
  late final _router = createRouter(sl<AuthBloc>());

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Singleton blocs — live for the app lifetime
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<JobsBloc>(
          create: (_) => sl<JobsBloc>(),
        ),
        BlocProvider<ApplicationsBloc>(
          create: (_) => sl<ApplicationsBloc>(),
        ),
        BlocProvider<ChatBloc>(
          create: (_) => sl<ChatBloc>(),
        ),
        BlocProvider<ProfileCubit>(
          create: (_) => sl<ProfileCubit>(),
        ),
        BlocProvider<SavedJobsCubit>(
          create: (_) => sl<SavedJobsCubit>(),
        ),
        BlocProvider<NotificationsCubit>(
          create: (_) => sl<NotificationsCubit>(),
        ),
        BlocProvider<EmployerBloc>(
          create: (_) => sl<EmployerBloc>(),
        ),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        // Rebuild only to pick up theme changes (theme stored in AuthState
        // future extension); for now rebuild on every auth state change so
        // the router redirect fires.
        buildWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
        builder: (context, authState) {
          return MaterialApp.router(
            title: 'CareerConnect',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
