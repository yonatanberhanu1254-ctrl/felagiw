import 'package:dartz/dartz.dart';
import 'package:career_connect/core/error/exceptions.dart';
import 'package:career_connect/core/error/failures.dart';
import 'package:career_connect/features/applications/data/datasources/applications_remote_datasource.dart';
import 'package:career_connect/features/applications/data/models/application_model.dart';
import 'package:career_connect/features/applications/domain/repositories/applications_repository.dart';

class ApplicationsRepositoryImpl implements ApplicationsRepository {
  final ApplicationsRemoteDataSource _dataSource;

  ApplicationsRepositoryImpl({required ApplicationsRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Either<Failure, ApplicationModel>> applyForJob(ApplicationModel application) async {
    try {
      final result = await _dataSource.applyForJob(application);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ApplicationModel>>> getStudentApplications(String studentId) async {
    try {
      final apps = await _dataSource.getStudentApplications(studentId);
      return Right(apps);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ApplicationModel>>> getJobApplicants(String jobId) async {
    try {
      final apps = await _dataSource.getJobApplicants(jobId);
      return Right(apps);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateApplicationStatus({
    required String applicationId,
    required String status,
  }) async {
    try {
      await _dataSource.updateApplicationStatus(applicationId: applicationId, status: status);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> hasApplied({required String jobId, required String studentId}) async {
    try {
      final result = await _dataSource.hasApplied(jobId: jobId, studentId: studentId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ApplicationModel>> getApplicationById(String applicationId) async {
    try {
      final app = await _dataSource.getApplicationById(applicationId);
      return Right(app);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Stream<List<ApplicationModel>> watchStudentApplications(String studentId) =>
      _dataSource.watchStudentApplications(studentId);
}
