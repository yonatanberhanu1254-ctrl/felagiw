import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:career_connect/features/jobs/data/models/job_model.dart';
import 'package:career_connect/features/saved_jobs/data/models/saved_job_model.dart';
import 'package:career_connect/features/saved_jobs/domain/repositories/saved_jobs_repository.dart';

class SavedJobsState extends Equatable {
  final List<SavedJobModel> savedJobs;
  final bool isLoading;
  final String? error;

  const SavedJobsState({this.savedJobs = const [], this.isLoading = false, this.error});

  SavedJobsState copyWith({List<SavedJobModel>? savedJobs, bool? isLoading, String? error}) =>
      SavedJobsState(
        savedJobs: savedJobs ?? this.savedJobs,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  bool isSaved(String jobId) => savedJobs.any((s) => s.jobId == jobId);

  @override
  List<Object?> get props => [savedJobs, isLoading, error];
}

class SavedJobsCubit extends Cubit<SavedJobsState> {
  final SavedJobsRepository _repository;
  SavedJobsCubit({required SavedJobsRepository repository})
      : _repository = repository,
        super(const SavedJobsState());

  Future<void> loadSavedJobs(String studentId) async {
    emit(state.copyWith(isLoading: true, error: null));
    final result = await _repository.getSavedJobs(studentId);
    result.fold(
      (f) => emit(state.copyWith(isLoading: false, error: f.message)),
      (jobs) => emit(state.copyWith(isLoading: false, savedJobs: jobs)),
    );
  }

  Future<void> toggleSave({required String studentId, required JobModel job}) async {
    if (state.isSaved(job.id)) {
      await unsaveJob(studentId: studentId, jobId: job.id);
    } else {
      await saveJob(studentId: studentId, job: job);
    }
  }

  Future<void> saveJob({required String studentId, required JobModel job}) async {
    final saved = SavedJobModel(
      id: '',
      studentId: studentId,
      jobId: job.id,
      jobTitle: job.title,
      companyName: job.companyName,
      companyLogoUrl: job.companyLogoUrl,
      jobType: job.jobType,
      location: job.location,
      remote: job.remote,
      salaryMin: job.salaryMin,
      salaryMax: job.salaryMax,
      savedAt: DateTime.now(),
      jobDeadline: job.deadline,
    );
    final result = await _repository.saveJob(saved);
    result.fold(
      (f) => emit(state.copyWith(error: f.message)),
      (_) => emit(state.copyWith(savedJobs: [saved, ...state.savedJobs])),
    );
  }

  Future<void> unsaveJob({required String studentId, required String jobId}) async {
    final result = await _repository.unsaveJob(studentId: studentId, jobId: jobId);
    result.fold(
      (f) => emit(state.copyWith(error: f.message)),
      (_) => emit(state.copyWith(
        savedJobs: state.savedJobs.where((s) => s.jobId != jobId).toList(),
      )),
    );
  }
}
