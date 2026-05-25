import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Employer
import 'package:career_connect/features/employer/data/datasources/employer_remote_datasource.dart';
import 'package:career_connect/features/employer/data/repositories/employer_repository_impl.dart';
import 'package:career_connect/features/employer/domain/repositories/employer_repository.dart';
import 'package:career_connect/features/employer/domain/usecases/employer_usecases.dart';
import 'package:career_connect/features/employer/presentation/bloc/employer_bloc.dart';

// Auth
import 'package:career_connect/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:career_connect/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:career_connect/features/auth/domain/repositories/auth_repository.dart';
import 'package:career_connect/features/auth/domain/usecases/auth_usecases.dart';
import 'package:career_connect/features/auth/presentation/bloc/auth_bloc.dart';

// Jobs
import 'package:career_connect/features/jobs/data/datasources/jobs_remote_datasource.dart';
import 'package:career_connect/features/jobs/data/repositories/jobs_repository_impl.dart';
import 'package:career_connect/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:career_connect/features/jobs/domain/usecases/jobs_usecases.dart';
import 'package:career_connect/features/jobs/presentation/bloc/jobs_bloc.dart';

// Applications
import 'package:career_connect/features/applications/data/datasources/applications_remote_datasource.dart';
import 'package:career_connect/features/applications/data/repositories/applications_repository_impl.dart';
import 'package:career_connect/features/applications/domain/repositories/applications_repository.dart';
import 'package:career_connect/features/applications/domain/usecases/application_usecases.dart';
import 'package:career_connect/features/applications/presentation/bloc/applications_bloc.dart';

// Chat
import 'package:career_connect/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:career_connect/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:career_connect/features/chat/domain/repositories/chat_repository.dart';
import 'package:career_connect/features/chat/presentation/bloc/chat_bloc.dart';

// Profile
import 'package:career_connect/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:career_connect/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:career_connect/features/profile/domain/repositories/profile_repository.dart';
import 'package:career_connect/features/profile/presentation/cubit/profile_cubit.dart';

// Saved Jobs
import 'package:career_connect/features/saved_jobs/data/datasources/saved_jobs_remote_datasource.dart';
import 'package:career_connect/features/saved_jobs/data/repositories/saved_jobs_repository_impl.dart';
import 'package:career_connect/features/saved_jobs/domain/repositories/saved_jobs_repository.dart';
import 'package:career_connect/features/saved_jobs/presentation/cubit/saved_jobs_cubit.dart';

// Notifications
import 'package:career_connect/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:career_connect/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:career_connect/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:career_connect/features/notifications/presentation/cubit/notifications_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── Firebase ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());

  // ── Auth ───────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(auth: sl(), firestore: sl(), googleSignIn: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => LoginWithEmail(sl()));
  sl.registerLazySingleton(() => RegisterStudent(sl()));
  sl.registerLazySingleton(() => RegisterEmployer(sl()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SendPasswordResetEmail(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(
    () => AuthBloc(
      getCurrentUser: sl(),
      loginWithEmail: sl(),
      registerStudent: sl(),
      registerEmployer: sl(),
      signInWithGoogle: sl(),
      sendPasswordResetEmail: sl(),
      signOut: sl(),
    ),
  );

  // ── Jobs ───────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<JobsRemoteDataSource>(
    () => JobsRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<JobsRepository>(
    () => JobsRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton(() => GetJobs(sl()));
  sl.registerLazySingleton(() => GetJobById(sl()));
  sl.registerLazySingleton(() => GetRecommendedJobs(sl()));
  sl.registerLazySingleton(() => GetRecentJobs(sl()));
  sl.registerLazySingleton(() => CreateJob(sl()));
  sl.registerLazySingleton(() => UpdateJob(sl()));
  sl.registerLazySingleton(() => DeleteJob(sl()));
  sl.registerLazySingleton(() => GetEmployerJobs(sl()));
  sl.registerFactory(
    () => JobsBloc(getJobs: sl(), getRecommendedJobs: sl(), getRecentJobs: sl(), createJob: sl()),
  );
  sl.registerFactory(() => JobDetailCubit(getJobById: sl()));

  // ── Applications ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<ApplicationsRemoteDataSource>(
    () => ApplicationsRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<ApplicationsRepository>(
    () => ApplicationsRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton(() => ApplyForJob(sl()));
  sl.registerLazySingleton(() => GetStudentApplications(sl()));
  sl.registerLazySingleton(() => GetJobApplicants(sl()));
  sl.registerLazySingleton(() => UpdateApplicationStatus(sl()));
  sl.registerLazySingleton(() => CheckHasApplied(sl()));
  sl.registerFactory(
    () => ApplicationsBloc(
      applyForJob: sl(),
      getStudentApplications: sl(),
      getJobApplicants: sl(),
      updateApplicationStatus: sl(),
    ),
  );

  // ── Profile ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(firestore: sl(), storage: sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(dataSource: sl()),
  );
  sl.registerFactory(() => ProfileCubit(repository: sl()));

  // ── Chat ───────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(dataSource: sl()),
  );
  sl.registerFactory(() => ChatBloc(repository: sl()));

  // ── Saved Jobs ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<SavedJobsRemoteDataSource>(
    () => SavedJobsRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<SavedJobsRepository>(
    () => SavedJobsRepositoryImpl(dataSource: sl()),
  );
  sl.registerFactory(() => SavedJobsCubit(repository: sl()));

  // ── Notifications ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(dataSource: sl()),
  );
  sl.registerFactory(() => NotificationsCubit(repository: sl()));

  // ── Employer ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton<EmployerRemoteDataSource>(
    () => EmployerRemoteDataSourceImpl(firestore: sl(), storage: sl()),
  );
  sl.registerLazySingleton<EmployerRepository>(
    () => EmployerRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton(() => GetEmployerProfile(sl()));
  sl.registerLazySingleton(() => UpdateEmployerProfile(sl()));
  sl.registerLazySingleton(() => UploadCompanyLogo(sl()));
  sl.registerFactory(
    () => EmployerBloc(
      getEmployerProfile: sl(),
      updateEmployerProfile: sl(),
      uploadCompanyLogo: sl(),
    ),
  );
}
