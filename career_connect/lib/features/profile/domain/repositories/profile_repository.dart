import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:career_connect/core/error/failures.dart';
import 'package:career_connect/features/auth/data/models/user_model.dart';
import 'package:career_connect/features/auth/data/models/employer_model.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserModel>> getStudentProfile(String uid);
  Future<Either<Failure, void>> updateStudentProfile(UserModel user);
  Future<Either<Failure, String>> uploadProfileImage({required String uid, required File imageFile});
  Future<Either<Failure, String>> uploadResume({required String uid, required File resumeFile});
  Future<Either<Failure, EmployerModel>> getEmployerProfile(String uid);
  Future<Either<Failure, void>> updateEmployerProfile(EmployerModel employer);
  Future<Either<Failure, String>> uploadCompanyLogo({required String uid, required File imageFile});
}
