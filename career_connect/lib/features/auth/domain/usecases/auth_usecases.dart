import 'package:dartz/dartz.dart';
import 'package:career_connect/core/error/failures.dart';
import 'package:career_connect/features/auth/data/models/user_model.dart';
import 'package:career_connect/features/auth/domain/repositories/auth_repository.dart';
import 'package:career_connect/core/utils/use_case.dart';

class LoginWithEmail implements UseCase<UserModel, LoginParams> {
  final AuthRepository repository;
  LoginWithEmail(this.repository);

  @override
  Future<Either<Failure, UserModel>> call(LoginParams params) =>
      repository.loginWithEmail(email: params.email, password: params.password);
}

class LoginParams {
  final String email;
  final String password;
  const LoginParams({required this.email, required this.password});
}

// ---------------------------------------------------------------------------

class RegisterStudent implements UseCase<UserModel, RegisterStudentParams> {
  final AuthRepository repository;
  RegisterStudent(this.repository);

  @override
  Future<Either<Failure, UserModel>> call(RegisterStudentParams params) =>
      repository.registerStudent(
        name: params.name,
        email: params.email,
        password: params.password,
      );
}

class RegisterStudentParams {
  final String name;
  final String email;
  final String password;
  const RegisterStudentParams({required this.name, required this.email, required this.password});
}

// ---------------------------------------------------------------------------

class RegisterEmployer {
  final AuthRepository repository;
  RegisterEmployer(this.repository);

  Future<Either<Failure, dynamic>> call(RegisterEmployerParams params) =>
      repository.registerEmployer(
        name: params.name,
        email: params.email,
        password: params.password,
        companyName: params.companyName,
      );
}

class RegisterEmployerParams {
  final String name;
  final String email;
  final String password;
  final String companyName;
  const RegisterEmployerParams({
    required this.name,
    required this.email,
    required this.password,
    required this.companyName,
  });
}

// ---------------------------------------------------------------------------

class SignInWithGoogle implements UseCaseNoParams<UserModel> {
  final AuthRepository repository;
  SignInWithGoogle(this.repository);

  @override
  Future<Either<Failure, UserModel>> call() => repository.signInWithGoogle();
}

// ---------------------------------------------------------------------------

class SendPasswordResetEmail implements UseCase<void, String> {
  final AuthRepository repository;
  SendPasswordResetEmail(this.repository);

  @override
  Future<Either<Failure, void>> call(String email) =>
      repository.sendPasswordResetEmail(email);
}

// ---------------------------------------------------------------------------

class SignOut implements UseCaseNoParams<void> {
  final AuthRepository repository;
  SignOut(this.repository);

  @override
  Future<Either<Failure, void>> call() => repository.signOut();
}

// ---------------------------------------------------------------------------

class GetCurrentUser implements UseCaseNoParams<UserModel?> {
  final AuthRepository repository;
  GetCurrentUser(this.repository);

  @override
  Future<Either<Failure, UserModel?>> call() => repository.getCurrentUser();
}
