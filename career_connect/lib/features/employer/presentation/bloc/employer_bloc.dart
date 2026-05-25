import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:career_connect/features/auth/data/models/employer_model.dart';
import 'package:career_connect/features/employer/domain/usecases/employer_usecases.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class EmployerState extends Equatable {
  final EmployerModel? employer;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? successMessage;

  const EmployerState({
    this.employer,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.successMessage,
  });

  EmployerState copyWith({
    EmployerModel? employer,
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? successMessage,
  }) =>
      EmployerState(
        employer: employer ?? this.employer,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        error: error,
        successMessage: successMessage,
      );

  @override
  List<Object?> get props =>
      [employer, isLoading, isSaving, error, successMessage];
}

// ── Events ────────────────────────────────────────────────────────────────────

abstract class EmployerEvent extends Equatable {
  const EmployerEvent();
  @override
  List<Object?> get props => [];
}

class EmployerLoadProfile extends EmployerEvent {
  final String uid;
  const EmployerLoadProfile(this.uid);
  @override
  List<Object?> get props => [uid];
}

class EmployerUpdateProfile extends EmployerEvent {
  final EmployerModel employer;
  const EmployerUpdateProfile(this.employer);
  @override
  List<Object?> get props => [employer];
}

class EmployerUploadLogo extends EmployerEvent {
  final String uid;
  final String filePath;
  const EmployerUploadLogo({required this.uid, required this.filePath});
  @override
  List<Object?> get props => [uid, filePath];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

class EmployerBloc extends Bloc<EmployerEvent, EmployerState> {
  final GetEmployerProfile _getEmployerProfile;
  final UpdateEmployerProfile _updateEmployerProfile;
  final UploadCompanyLogo _uploadCompanyLogo;

  EmployerBloc({
    required GetEmployerProfile getEmployerProfile,
    required UpdateEmployerProfile updateEmployerProfile,
    required UploadCompanyLogo uploadCompanyLogo,
  })  : _getEmployerProfile = getEmployerProfile,
        _updateEmployerProfile = updateEmployerProfile,
        _uploadCompanyLogo = uploadCompanyLogo,
        super(const EmployerState()) {
    on<EmployerLoadProfile>(_onLoadProfile);
    on<EmployerUpdateProfile>(_onUpdateProfile);
    on<EmployerUploadLogo>(_onUploadLogo);
  }

  Future<void> _onLoadProfile(
      EmployerLoadProfile event, Emitter<EmployerState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    final result = await _getEmployerProfile(event.uid);
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (employer) => emit(state.copyWith(isLoading: false, employer: employer)),
    );
  }

  Future<void> _onUpdateProfile(
      EmployerUpdateProfile event, Emitter<EmployerState> emit) async {
    emit(state.copyWith(isSaving: true, error: null, successMessage: null));
    final result = await _updateEmployerProfile(event.employer);
    result.fold(
      (failure) =>
          emit(state.copyWith(isSaving: false, error: failure.message)),
      (_) => emit(state.copyWith(
        isSaving: false,
        employer: event.employer,
        successMessage: 'Profile updated successfully',
      )),
    );
  }

  Future<void> _onUploadLogo(
      EmployerUploadLogo event, Emitter<EmployerState> emit) async {
    emit(state.copyWith(isSaving: true, error: null));
    final result = await _uploadCompanyLogo(
        uid: event.uid, filePath: event.filePath);
    result.fold(
      (failure) =>
          emit(state.copyWith(isSaving: false, error: failure.message)),
      (url) {
        final updated = state.employer?.copyWith(logoUrl: url);
        emit(state.copyWith(
          isSaving: false,
          employer: updated,
          successMessage: 'Logo uploaded successfully',
        ));
      },
    );
  }
}
