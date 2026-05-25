import 'package:dartz/dartz.dart';
import 'package:career_connect/core/error/exceptions.dart';
import 'package:career_connect/core/error/failures.dart';
import 'package:career_connect/features/saved_jobs/data/datasources/saved_jobs_remote_datasource.dart';
import 'package:career_connect/features/saved_jobs/data/models/saved_job_model.dart';
import 'package:career_connect/features/saved_jobs/domain/repositories/saved_jobs_repository.dart';

class SavedJobsRepositoryImpl implements SavedJobsRepository {
  final SavedJobsRemoteDataSource _dataSource;
  SavedJobsRepositoryImpl({required SavedJobsRemoteDataSource dataSource}) : _dataSource = dataSource;

  @override
  Future<Either<Failure, List<SavedJobModel>>> getSavedJobs(String studentId) async {
    try { return Right(await _dataSource.getSavedJobs(studentId)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message)); }
  }

  @override
  Future<Either<Failure, void>> saveJob(SavedJobModel savedJob) async {
    try { await _dataSource.saveJob(savedJob); return const Right(null); }
    on ServerException catch (e) { return Left(ServerFailure(e.message)); }
  }

  @override
  Future<Either<Failure, void>> unsaveJob({required String studentId, required String jobId}) async {
    try { await _dataSource.unsaveJob(studentId: studentId, jobId: jobId); return const Right(null); }
    on ServerException catch (e) { return Left(ServerFailure(e.message)); }
  }

  @override
  Future<Either<Failure, bool>> isJobSaved({required String studentId, required String jobId}) async {
    try { return Right(await _dataSource.isJobSaved(studentId: studentId, jobId: jobId)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message)); }
  }
}
