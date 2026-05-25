import 'package:dartz/dartz.dart';
import 'package:career_connect/core/error/failures.dart';
import 'package:career_connect/features/applications/data/models/application_model.dart';

/// Applications repository interface.
abstract class ApplicationsRepository {
  /// Submit a new job application.
  Future<Either<Failure, ApplicationModel>> applyForJob(ApplicationModel application);

  /// Get all applications for the current student.
  Future<Either<Failure, List<ApplicationModel>>> getStudentApplications(String studentId);

  /// Get all applicants for a specific job (employer view).
  Future<Either<Failure, List<ApplicationModel>>> getJobApplicants(String jobId);

  /// Update application status (employer action).
  Future<Either<Failure, void>> updateApplicationStatus({
    required String applicationId,
    required String status,
  });

  /// Check if a student has already applied for a job.
  Future<Either<Failure, bool>> hasApplied({
    required String jobId,
    required String studentId,
  });

  /// Get a single application by ID.
  Future<Either<Failure, ApplicationModel>> getApplicationById(String applicationId);

  /// Stream of applications for real-time updates.
  Stream<List<ApplicationModel>> watchStudentApplications(String studentId);
}
