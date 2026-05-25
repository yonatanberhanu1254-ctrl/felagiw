import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:career_connect/features/auth/data/models/user_model.dart';
import 'package:career_connect/features/auth/domain/usecases/auth_usecases.dart';

// ── Events ──────────────────────────────────────────────────────────────────

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginWithEmail extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginWithEmail({required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}

class AuthRegisterStudent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const AuthRegisterStudent({required this.name, required this.email, required this.password});
  @override
  List<Object> get props => [name, email, password];
}

class AuthRegisterEmployer extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String companyName;
  const AuthRegisterEmployer({required this.name, required this.email, required this.password, required this.companyName});
  @override
  List<Object> get props => [name, email, password, companyName];
}

class AuthGoogleSignIn extends AuthEvent {
  const AuthGoogleSignIn();
}

class AuthForgotPassword extends AuthEvent {
  final String email;
  const AuthForgotPassword(this.email);
  @override
  List<Object> get props => [email];
}

class AuthSignOut extends AuthEvent {
  const AuthSignOut();
}

// ── States ───────────────────────────────────────────────────────────────────

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated(this.user);
  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object> get props => [message];
}

class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent();
}

class AuthRegistrationSuccess extends AuthState {
  final UserModel user;
  final String role;
  const AuthRegistrationSuccess({required this.user, required this.role});
  @override
  List<Object> get props => [user, role];
}

// ── Bloc ─────────────────────────────────────────────────────────────────────

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUser _getCurrentUser;
  final LoginWithEmail _loginWithEmail;
  final RegisterStudent _registerStudent;
  final RegisterEmployer _registerEmployer;
  final SignInWithGoogle _signInWithGoogle;
  final SendPasswordResetEmail _sendPasswordResetEmail;
  final SignOut _signOut;

  AuthBloc({
    required GetCurrentUser getCurrentUser,
    required LoginWithEmail loginWithEmail,
    required RegisterStudent registerStudent,
    required RegisterEmployer registerEmployer,
    required SignInWithGoogle signInWithGoogle,
    required SendPasswordResetEmail sendPasswordResetEmail,
    required SignOut signOut,
  })  : _getCurrentUser = getCurrentUser,
        _loginWithEmail = loginWithEmail,
        _registerStudent = registerStudent,
        _registerEmployer = registerEmployer,
        _signInWithGoogle = signInWithGoogle,
        _sendPasswordResetEmail = sendPasswordResetEmail,
        _signOut = signOut,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginWithEmail>(_onLoginWithEmail);
    on<AuthRegisterStudent>(_onRegisterStudent);
    on<AuthRegisterEmployer>(_onRegisterEmployer);
    on<AuthGoogleSignIn>(_onGoogleSignIn);
    on<AuthForgotPassword>(_onForgotPassword);
    on<AuthSignOut>(_onSignOut);
  }

  Future<void> _onCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _getCurrentUser();
    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (user) => user != null
          ? emit(AuthAuthenticated(user))
          : emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onLoginWithEmail(AuthLoginWithEmail event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _loginWithEmail(LoginParams(email: event.email, password: event.password));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onRegisterStudent(AuthRegisterStudent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _registerStudent(
      RegisterStudentParams(name: event.name, email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthRegistrationSuccess(user: user, role: 'student')),
    );
  }

  Future<void> _onRegisterEmployer(AuthRegisterEmployer event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _registerEmployer(
      RegisterEmployerParams(
        name: event.name,
        email: event.email,
        password: event.password,
        companyName: event.companyName,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (employer) {
        // Wrap as a generic UserModel-like state
        final fakeUser = UserModel(
          uid: employer.uid,
          name: employer.name,
          email: employer.email,
          role: 'employer',
          createdAt: employer.createdAt,
        );
        emit(AuthRegistrationSuccess(user: fakeUser, role: 'employer'));
      },
    );
  }

  Future<void> _onGoogleSignIn(AuthGoogleSignIn event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _signInWithGoogle();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onForgotPassword(AuthForgotPassword event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _sendPasswordResetEmail(event.email);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthPasswordResetSent()),
    );
  }

  Future<void> _onSignOut(AuthSignOut event, Emitter<AuthState> emit) async {
    await _signOut();
    emit(const AuthUnauthenticated());
  }
}
