import 'package:dartz/dartz.dart';
import 'package:career_connect/core/error/failures.dart';
import 'package:career_connect/core/utils/use_case.dart';
import 'package:career_connect/features/applications/data/models/application_model.dart';
import 'package:career_connect/features/applications/domain/repositories/applications_repository.dart';

class ApplyForJob implements UseCase<ApplicationModel, ApplicationModel> {
  final ApplicationsRepository repository;
  ApplyForJob(this.repository);

  @override
  Future<Either<Failure, ApplicationModel>> call(ApplicationModel application) =>
      repository.applyForJob(application);
}

// ---------------------------------------------------------------------------

class GetStudentApplications implements UseCase<List<ApplicationModel>, String> {
  final ApplicationsRepository repository;
  GetStudentApplications(this.repository);

  @override
  Future<Either<Failure, List<ApplicationModel>>> call(String studentId) =>
      repository.getStudentApplications(studentId);
}

// ---------------------------------------------------------------------------

class GetJobApplicants implements UseCase<List<ApplicationModel>, String> {
  final ApplicationsRepository repository;
  GetJobApplicants(this.repository);

  @override
  Future<Either<Failure, List<ApplicationModel>>> call(String jobId) =>
      repository.getJobApplicants(jobId);
}

// ---------------------------------------------------------------------------

class UpdateApplicationStatus {
  final ApplicationsRepository repository;
  UpdateApplicationStatus(this.repository);

  Future<Either<Failure, void>> call({
    required String applicationId,
    required String status,
  }) =>
      repository.updateApplicationStatus(
        applicationId: applicationId,
        status: status,
      );
}

// ---------------------------------------------------------------------------

class CheckHasApplied {
  final ApplicationsRepository repository;
  CheckHasApplied(this.repository);

  Future<Either<Failure, bool>> call({
    required String jobId,
    required String studentId,
  }) =>
      repository.hasApplied(jobId: jobId, studentId: studentId);
}
