import 'package:dartz/dartz.dart';
import 'package:career_connect/core/error/failures.dart';
import 'package:career_connect/features/auth/data/models/user_model.dart';
import 'package:career_connect/features/auth/data/models/employer_model.dart';

/// Auth repository interface (domain layer).
abstract class AuthRepository {
  /// Returns the current signed-in user model, or null.
  Future<Either<Failure, UserModel?>> getCurrentUser();

  /// Sign in with email and password.
  Future<Either<Failure, UserModel>> loginWithEmail({
    required String email,
    required String password,
  });

  /// Register a new student account.
  Future<Either<Failure, UserModel>> registerStudent({
    required String name,
    required String email,
    required String password,
  });

  /// Register a new employer account.
  Future<Either<Failure, EmployerModel>> registerEmployer({
    required String name,
    required String email,
    required String password,
    required String companyName,
  });

  /// Sign in with Google.
  Future<Either<Failure, UserModel>> signInWithGoogle();

  /// Send password reset email.
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  /// Send email verification to the current user.
  Future<Either<Failure, void>> sendEmailVerification();

  /// Sign out.
  Future<Either<Failure, void>> signOut();

  /// Stream of auth state changes.
  Stream<UserModel?> get authStateChanges;
}
