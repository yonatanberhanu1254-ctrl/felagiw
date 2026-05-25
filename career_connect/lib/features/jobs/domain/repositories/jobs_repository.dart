import 'package:dartz/dartz.dart';
import 'package:career_connect/core/error/failures.dart';
import 'package:career_connect/features/jobs/data/models/job_model.dart';

/// Job search filter parameters.
class JobFilters {
  final String? query;
  final String? category;
  final String? jobType;
  final String? location;
  final String? experienceLevel;
  final double? minSalary;
  final double? maxSalary;
  final bool? remote;

  const JobFilters({
    this.query,
    this.category,
    this.jobType,
    this.location,
    this.experienceLevel,
    this.minSalary,
    this.maxSalary,
    this.remote,
  });

  JobFilters copyWith({
    String? query,
    String? category,
    String? jobType,
    String? location,
    String? experienceLevel,
    double? minSalary,
    double? maxSalary,
    bool? remote,
  }) =>
      JobFilters(
        query: query ?? this.query,
        category: category ?? this.category,
        jobType: jobType ?? this.jobType,
        location: location ?? this.location,
        experienceLevel: experienceLevel ?? this.experienceLevel,
        minSalary: minSalary ?? this.minSalary,
        maxSalary: maxSalary ?? this.maxSalary,
        remote: remote ?? this.remote,
      );

  bool get hasFilters =>
      query != null ||
      category != null ||
      jobType != null ||
      location != null ||
      experienceLevel != null ||
      minSalary != null ||
      maxSalary != null ||
      remote != null;
}

/// Jobs repository interface.
abstract class JobsRepository {
  /// Get paginated active jobs with optional filters.
  Future<Either<Failure, List<JobModel>>> getJobs({
    JobFilters? filters,
    Object? lastDocument,
    int limit = 15,
  });

  /// Get a single job by ID.
  Future<Either<Failure, JobModel>> getJobById(String jobId);

  /// Get recommended jobs for a student (based on skills + category).
  Future<Either<Failure, List<JobModel>>> getRecommendedJobs({
    required List<String> skills,
    required String userId,
    int limit = 10,
  });

  /// Get recent jobs (sorted by createdAt).
  Future<Either<Failure, List<JobModel>>> getRecentJobs({int limit = 8});

  /// Get jobs posted by a specific employer.
  Future<Either<Failure, List<JobModel>>> getEmployerJobs(String employerId);

  /// Create a new job posting.
  Future<Either<Failure, JobModel>> createJob(JobModel job);

  /// Update an existing job.
  Future<Either<Failure, void>> updateJob(JobModel job);

  /// Delete a job posting.
  Future<Either<Failure, void>> deleteJob(String jobId);

  /// Increment applicant count.
  Future<Either<Failure, void>> incrementApplicantCount(String jobId);
}
