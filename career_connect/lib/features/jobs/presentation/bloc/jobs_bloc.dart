import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:career_connect/features/jobs/data/models/job_model.dart';
import 'package:career_connect/features/jobs/domain/repositories/jobs_repository.dart';
import 'package:career_connect/features/jobs/domain/usecases/jobs_usecases.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class JobsState extends Equatable {
  final List<JobModel> jobs;
  final List<JobModel> recommendedJobs;
  final List<JobModel> recentJobs;
  final bool isLoading;
  final bool isPaginating;
  final bool hasMore;
  final String? error;
  final JobFilters filters;

  const JobsState({
    this.jobs = const [],
    this.recommendedJobs = const [],
    this.recentJobs = const [],
    this.isLoading = false,
    this.isPaginating = false,
    this.hasMore = true,
    this.error,
    this.filters = const JobFilters(),
  });

  JobsState copyWith({
    List<JobModel>? jobs,
    List<JobModel>? recommendedJobs,
    List<JobModel>? recentJobs,
    bool? isLoading,
    bool? isPaginating,
    bool? hasMore,
    String? error,
    JobFilters? filters,
  }) =>
      JobsState(
        jobs: jobs ?? this.jobs,
        recommendedJobs: recommendedJobs ?? this.recommendedJobs,
        recentJobs: recentJobs ?? this.recentJobs,
        isLoading: isLoading ?? this.isLoading,
        isPaginating: isPaginating ?? this.isPaginating,
        hasMore: hasMore ?? this.hasMore,
        error: error,
        filters: filters ?? this.filters,
      );

  @override
  List<Object?> get props => [jobs, recommendedJobs, recentJobs, isLoading, isPaginating, hasMore, error, filters];
}

// ── Events ────────────────────────────────────────────────────────────────────

abstract class JobsEvent extends Equatable {
  const JobsEvent();
  @override
  List<Object?> get props => [];
}

class JobsLoadHome extends JobsEvent {
  final List<String> skills;
  final String userId;
  const JobsLoadHome({required this.skills, required this.userId});
}

class JobsLoadMore extends JobsEvent {
  const JobsLoadMore();
}

class JobsApplyFilters extends JobsEvent {
  final JobFilters filters;
  const JobsApplyFilters(this.filters);
  @override
  List<Object?> get props => [filters];
}

class JobsClearFilters extends JobsEvent {
  const JobsClearFilters();
}

class JobsCreateJob extends JobsEvent {
  final JobModel job;
  const JobsCreateJob(this.job);
  @override
  List<Object?> get props => [job];
}

class JobsRefresh extends JobsEvent {
  const JobsRefresh();
}

// ── Cubit for single job detail ───────────────────────────────────────────────

class JobDetailState extends Equatable {
  final JobModel? job;
  final bool isLoading;
  final bool hasApplied;
  final bool isSaved;
  final String? error;

  const JobDetailState({
    this.job,
    this.isLoading = false,
    this.hasApplied = false,
    this.isSaved = false,
    this.error,
  });

  JobDetailState copyWith({
    JobModel? job,
    bool? isLoading,
    bool? hasApplied,
    bool? isSaved,
    String? error,
  }) =>
      JobDetailState(
        job: job ?? this.job,
        isLoading: isLoading ?? this.isLoading,
        hasApplied: hasApplied ?? this.hasApplied,
        isSaved: isSaved ?? this.isSaved,
        error: error,
      );

  @override
  List<Object?> get props => [job, isLoading, hasApplied, isSaved, error];
}

class JobDetailCubit extends Cubit<JobDetailState> {
  final GetJobById _getJobById;

  JobDetailCubit({required GetJobById getJobById})
      : _getJobById = getJobById,
        super(const JobDetailState());

  Future<void> load(String jobId) async {
    emit(state.copyWith(isLoading: true, error: null));
    final result = await _getJobById(jobId);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (job) => emit(state.copyWith(isLoading: false, job: job)),
    );
  }

  void setHasApplied(bool value) => emit(state.copyWith(hasApplied: value));
  void setIsSaved(bool value) => emit(state.copyWith(isSaved: value));
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

class JobsBloc extends Bloc<JobsEvent, JobsState> {
  final GetJobs _getJobs;
  final GetRecommendedJobs _getRecommendedJobs;
  final GetRecentJobs _getRecentJobs;
  final CreateJob _createJob;

  Object? _lastDocument;

  JobsBloc({
    required GetJobs getJobs,
    required GetRecommendedJobs getRecommendedJobs,
    required GetRecentJobs getRecentJobs,
    required CreateJob createJob,
  })  : _getJobs = getJobs,
        _getRecommendedJobs = getRecommendedJobs,
        _getRecentJobs = getRecentJobs,
        _createJob = createJob,
        super(const JobsState()) {
    on<JobsLoadHome>(_onLoadHome);
    on<JobsLoadMore>(_onLoadMore);
    on<JobsApplyFilters>(_onApplyFilters);
    on<JobsClearFilters>(_onClearFilters);
    on<JobsRefresh>(_onRefresh);
    on<JobsCreateJob>(_onCreateJob);
  }

  Future<void> _onLoadHome(JobsLoadHome event, Emitter<JobsState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    _lastDocument = null;

    final results = await Future.wait([
      _getRecentJobs(limit: 15),
      _getRecommendedJobs(skills: event.skills, userId: event.userId, limit: 10),
    ]);

    final recentResult = results[0];
    final recommendedResult = results[1];

    List<JobModel> jobs = [];
    List<JobModel> recommended = [];
    String? error;

    recentResult.fold((f) => error = f.message, (list) => jobs = list);
    recommendedResult.fold((_) {}, (list) => recommended = list);

    emit(state.copyWith(
      jobs: jobs,
      recentJobs: jobs,
      recommendedJobs: recommended,
      isLoading: false,
      hasMore: jobs.length >= 15,
      error: error,
    ));
  }

  Future<void> _onLoadMore(JobsLoadMore event, Emitter<JobsState> emit) async {
    if (state.isPaginating || !state.hasMore) return;
    emit(state.copyWith(isPaginating: true));

    final result = await _getJobs(GetJobsParams(
      filters: state.filters,
      lastDocument: _lastDocument,
      limit: 15,
    ));

    result.fold(
      (failure) => emit(state.copyWith(isPaginating: false, error: failure.message)),
      (newJobs) {
        if (newJobs.isNotEmpty) _lastDocument = newJobs.last;
        emit(state.copyWith(
          jobs: [...state.jobs, ...newJobs],
          isPaginating: false,
          hasMore: newJobs.length >= 15,
        ));
      },
    );
  }

  Future<void> _onApplyFilters(JobsApplyFilters event, Emitter<JobsState> emit) async {
    emit(state.copyWith(isLoading: true, filters: event.filters, error: null));
    _lastDocument = null;

    final result = await _getJobs(GetJobsParams(filters: event.filters));
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (jobs) => emit(state.copyWith(
        jobs: jobs,
        isLoading: false,
        hasMore: jobs.length >= 15,
      )),
    );
  }

  Future<void> _onClearFilters(JobsClearFilters event, Emitter<JobsState> emit) async {
    add(const JobsRefresh());
  }

  Future<void> _onRefresh(JobsRefresh event, Emitter<JobsState> emit) async {
    emit(state.copyWith(isLoading: true, error: null, filters: const JobFilters()));
    _lastDocument = null;
    final result = await _getJobs(const GetJobsParams());
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (jobs) => emit(state.copyWith(jobs: jobs, isLoading: false, hasMore: jobs.length >= 15)),
    );
  }

  Future<void> _onCreateJob(JobsCreateJob event, Emitter<JobsState> emit) async {
    final result = await _createJob(event.job);
    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (createdJob) {
        // Prepend the new job to the current list for instant optimistic update
        emit(state.copyWith(
          jobs: [createdJob, ...state.jobs],
          error: null,
        ));
      },
    );
  }
}
