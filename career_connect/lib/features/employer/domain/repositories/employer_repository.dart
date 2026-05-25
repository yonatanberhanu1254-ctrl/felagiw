import 'package:dartz/dartz.dart';
import 'package:career_connect/core/error/failures.dart';
import 'package:career_connect/features/auth/data/models/employer_model.dart';

abstract class EmployerRepository {
  Future<Either<Failure, EmployerModel>> getEmployerProfile(String uid);
  Future<Either<Failure, void>> updateEmployerProfile(EmployerModel employer);
  Future<Either<Failure, String>> uploadCompanyLogo({
    required String uid,
    required String filePath,
  });
}
