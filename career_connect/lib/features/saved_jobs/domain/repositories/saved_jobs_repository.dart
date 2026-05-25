import 'package:dartz/dartz.dart';
import 'package:career_connect/core/error/failures.dart';
import 'package:career_connect/features/saved_jobs/data/models/saved_job_model.dart';

abstract class SavedJobsRepository {
  Future<Either<Failure, List<SavedJobModel>>> getSavedJobs(String studentId);
  Future<Either<Failure, void>> saveJob(SavedJobModel savedJob);
  Future<Either<Failure, void>> unsaveJob({required String studentId, required String jobId});
  Future<Either<Failure, bool>> isJobSaved({required String studentId, required String jobId});
}
