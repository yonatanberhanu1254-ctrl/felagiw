import 'package:dartz/dartz.dart';
import 'package:career_connect/core/error/failures.dart';
import 'package:career_connect/core/utils/use_case.dart';
import 'package:career_connect/features/jobs/data/models/job_model.dart';
import 'package:career_connect/features/jobs/domain/repositories/jobs_repository.dart';

class GetJobs implements UseCase<List<JobModel>, GetJobsParams> {
  final JobsRepository repository;
  GetJobs(this.repository);

  @override
  Future<Either<Failure, List<JobModel>>> call(GetJobsParams params) =>
      repository.getJobs(
        filters: params.filters,
        lastDocument: params.lastDocument,
        limit: params.limit,
      );
}

class GetJobsParams {
  final JobFilters? filters;
  final Object? lastDocument;
  final int limit;
  const GetJobsParams({this.filters, this.lastDocument, this.limit = 15});
}

// ---------------------------------------------------------------------------

class GetJobById implements UseCase<JobModel, String> {
  final JobsRepository repository;
  GetJobById(this.repository);

  @override
  Future<Either<Failure, JobModel>> call(String jobId) =>
      repository.getJobById(jobId);
}

// ---------------------------------------------------------------------------

class GetRecommendedJobs {
  final JobsRepository repository;
  GetRecommendedJobs(this.repository);

  Future<Either<Failure, List<JobModel>>> call({
    required List<String> skills,
    required String userId,
    int limit = 10,
  }) =>
      repository.getRecommendedJobs(skills: skills, userId: userId, limit: limit);
}

// ---------------------------------------------------------------------------

class GetRecentJobs {
  final JobsRepository repository;
  GetRecentJobs(this.repository);

  Future<Either<Failure, List<JobModel>>> call({int limit = 8}) =>
      repository.getRecentJobs(limit: limit);
}

// ---------------------------------------------------------------------------

class CreateJob implements UseCase<JobModel, JobModel> {
  final JobsRepository repository;
  CreateJob(this.repository);

  @override
  Future<Either<Failure, JobModel>> call(JobModel job) =>
      repository.createJob(job);
}

// ---------------------------------------------------------------------------

class UpdateJob implements UseCase<void, JobModel> {
  final JobsRepository repository;
  UpdateJob(this.repository);

  @override
  Future<Either<Failure, void>> call(JobModel job) =>
      repository.updateJob(job);
}

// ---------------------------------------------------------------------------

class DeleteJob implements UseCase<void, String> {
  final JobsRepository repository;
  DeleteJob(this.repository);

  @override
  Future<Either<Failure, void>> call(String jobId) =>
      repository.deleteJob(jobId);
}

// ---------------------------------------------------------------------------

class GetEmployerJobs implements UseCase<List<JobModel>, String> {
  final JobsRepository repository;
  GetEmployerJobs(this.repository);

  @override
  Future<Either<Failure, List<JobModel>>> call(String employerId) =>
      repository.getEmployerJobs(employerId);
}
