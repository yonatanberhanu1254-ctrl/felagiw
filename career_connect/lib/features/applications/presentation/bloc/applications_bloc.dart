import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:career_connect/features/applications/data/models/application_model.dart';
import 'package:career_connect/features/applications/domain/usecases/application_usecases.dart';

// ── States ────────────────────────────────────────────────────────────────────

class ApplicationsState extends Equatable {
  final List<ApplicationModel> applications;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final String? successMessage;

  const ApplicationsState({
    this.applications = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.successMessage,
  });

  ApplicationsState copyWith({
    List<ApplicationModel>? applications,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    String? successMessage,
  }) =>
      ApplicationsState(
        applications: applications ?? this.applications,
        isLoading: isLoading ?? this.isLoading,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error: error,
        successMessage: successMessage,
      );

  @override
  List<Object?> get props => [applications, isLoading, isSubmitting, error, successMessage];
}

// ── Events ────────────────────────────────────────────────────────────────────

abstract class ApplicationsEvent extends Equatable {
  const ApplicationsEvent();
  @override
  List<Object?> get props => [];
}

class LoadStudentApplications extends ApplicationsEvent {
  final String studentId;
  const LoadStudentApplications(this.studentId);
  @override
  List<Object> get props => [studentId];
}

class SubmitApplication extends ApplicationsEvent {
  final ApplicationModel application;
  const SubmitApplication(this.application);
  @override
  List<Object> get props => [application];
}

class LoadJobApplicants extends ApplicationsEvent {
  final String jobId;
  const LoadJobApplicants(this.jobId);
  @override
  List<Object> get props => [jobId];
}

class UpdateApplicationStatusEvent extends ApplicationsEvent {
  final String applicationId;
  final String status;
  const UpdateApplicationStatusEvent({required this.applicationId, required this.status});
  @override
  List<Object> get props => [applicationId, status];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

class ApplicationsBloc extends Bloc<ApplicationsEvent, ApplicationsState> {
  final ApplyForJob _applyForJob;
  final GetStudentApplications _getStudentApplications;
  final GetJobApplicants _getJobApplicants;
  final UpdateApplicationStatus _updateApplicationStatus;

  ApplicationsBloc({
    required ApplyForJob applyForJob,
    required GetStudentApplications getStudentApplications,
    required GetJobApplicants getJobApplicants,
    required UpdateApplicationStatus updateApplicationStatus,
  })  : _applyForJob = applyForJob,
        _getStudentApplications = getStudentApplications,
        _getJobApplicants = getJobApplicants,
        _updateApplicationStatus = updateApplicationStatus,
        super(const ApplicationsState()) {
    on<LoadStudentApplications>(_onLoadStudentApplications);
    on<SubmitApplication>(_onSubmitApplication);
    on<LoadJobApplicants>(_onLoadJobApplicants);
    on<UpdateApplicationStatusEvent>(_onUpdateStatus);
  }

  Future<void> _onLoadStudentApplications(
    LoadStudentApplications event,
    Emitter<ApplicationsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    final result = await _getStudentApplications(event.studentId);
    result.fold(
      (f) => emit(state.copyWith(isLoading: false, error: f.message)),
      (apps) => emit(state.copyWith(isLoading: false, applications: apps)),
    );
  }

  Future<void> _onSubmitApplication(
    SubmitApplication event,
    Emitter<ApplicationsState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, error: null));
    final result = await _applyForJob(event.application);
    result.fold(
      (f) => emit(state.copyWith(isSubmitting: false, error: f.message)),
      (app) => emit(state.copyWith(
        isSubmitting: false,
        applications: [app, ...state.applications],
        successMessage: 'Application submitted successfully!',
      )),
    );
  }

  Future<void> _onLoadJobApplicants(
    LoadJobApplicants event,
    Emitter<ApplicationsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    final result = await _getJobApplicants(event.jobId);
    result.fold(
      (f) => emit(state.copyWith(isLoading: false, error: f.message)),
      (apps) => emit(state.copyWith(isLoading: false, applications: apps)),
    );
  }

  Future<void> _onUpdateStatus(
    UpdateApplicationStatusEvent event,
    Emitter<ApplicationsState> emit,
  ) async {
    final result = await _updateApplicationStatus(
      applicationId: event.applicationId,
      status: event.status,
    );
    result.fold(
      (f) => emit(state.copyWith(error: f.message)),
      (_) {
        final updated = state.applications.map((app) {
          if (app.id == event.applicationId) return app.copyWith(status: event.status);
          return app;
        }).toList();
        emit(state.copyWith(applications: updated, successMessage: 'Status updated.'));
      },
    );
  }
}
