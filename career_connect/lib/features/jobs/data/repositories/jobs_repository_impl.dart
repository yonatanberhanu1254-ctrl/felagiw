import 'package:dartz/dartz.dart';
import 'package:career_connect/core/error/exceptions.dart';
import 'package:career_connect/core/error/failures.dart';
import 'package:career_connect/features/jobs/data/datasources/jobs_remote_datasource.dart';
import 'package:career_connect/features/jobs/data/models/job_model.dart';
import 'package:career_connect/features/jobs/domain/repositories/jobs_repository.dart';

class JobsRepositoryImpl implements JobsRepository {
  final JobsRemoteDataSource _dataSource;

  JobsRepositoryImpl({required JobsRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Either<Failure, List<JobModel>>> getJobs({
    JobFilters? filters,
    Object? lastDocument,
    int limit = 15,
  }) async {
    try {
      final jobs = await _dataSource.getJobs(
        filters: filters,
        lastDocument: lastDocument,
        limit: limit,
      );
      return Right(jobs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, JobModel>> getJobById(String jobId) async {
    try {
      final job = await _dataSource.getJobById(jobId);
      return Right(job);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<JobModel>>> getRecommendedJobs({
    required List<String> skills,
    required String userId,
    int limit = 10,
  }) async {
    try {
      final jobs = await _dataSource.getRecommendedJobs(
        skills: skills,
        userId: userId,
        limit: limit,
      );
      return Right(jobs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<JobModel>>> getRecentJobs({int limit = 8}) async {
    try {
      final jobs = await _dataSource.getRecentJobs(limit: limit);
      return Right(jobs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<JobModel>>> getEmployerJobs(String employerId) async {
    try {
      final jobs = await _dataSource.getEmployerJobs(employerId);
      return Right(jobs);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, JobModel>> createJob(JobModel job) async {
    try {
      final created = await _dataSource.createJob(job);
      return Right(created);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateJob(JobModel job) async {
    try {
      await _dataSource.updateJob(job);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteJob(String jobId) async {
    try {
      await _dataSource.deleteJob(jobId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> incrementApplicantCount(String jobId) async {
    try {
      await _dataSource.incrementApplicantCount(jobId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
