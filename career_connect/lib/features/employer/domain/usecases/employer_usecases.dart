import 'package:dartz/dartz.dart';
import 'package:career_connect/core/error/failures.dart';
import 'package:career_connect/features/auth/data/models/employer_model.dart';
import 'package:career_connect/features/employer/domain/repositories/employer_repository.dart';

class GetEmployerProfile {
  final EmployerRepository _repository;
  GetEmployerProfile(this._repository);

  Future<Either<Failure, EmployerModel>> call(String uid) =>
      _repository.getEmployerProfile(uid);
}

// ─────────────────────────────────────────────────────────────────────────────

class UpdateEmployerProfile {
  final EmployerRepository _repository;
  UpdateEmployerProfile(this._repository);

  Future<Either<Failure, void>> call(EmployerModel employer) =>
      _repository.updateEmployerProfile(employer);
}

// ─────────────────────────────────────────────────────────────────────────────

class UploadCompanyLogo {
  final EmployerRepository _repository;
  UploadCompanyLogo(this._repository);

  Future<Either<Failure, String>> call({
    required String uid,
    required String filePath,
  }) =>
      _repository.uploadCompanyLogo(uid: uid, filePath: filePath);
}
