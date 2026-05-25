import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:career_connect/features/auth/data/models/employer_model.dart';
import 'package:career_connect/features/auth/data/models/user_model.dart';
import 'package:career_connect/features/profile/domain/repositories/profile_repository.dart';

class ProfileState extends Equatable {
  final UserModel? student;
  final EmployerModel? employer;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? successMessage;

  const ProfileState({
    this.student,
    this.employer,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.successMessage,
  });

  ProfileState copyWith({
    UserModel? student,
    EmployerModel? employer,
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? successMessage,
  }) =>
      ProfileState(
        student: student ?? this.student,
        employer: employer ?? this.employer,
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        error: error,
        successMessage: successMessage,
      );

  @override
  List<Object?> get props => [student, employer, isLoading, isSaving, error, successMessage];
}

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;
  ProfileCubit({required ProfileRepository repository})
      : _repository = repository,
        super(const ProfileState());

  Future<void> loadStudentProfile(String uid) async {
    emit(state.copyWith(isLoading: true, error: null));
    final result = await _repository.getStudentProfile(uid);
    result.fold(
      (f) => emit(state.copyWith(isLoading: false, error: f.message)),
      (user) => emit(state.copyWith(isLoading: false, student: user)),
    );
  }

  Future<void> loadEmployerProfile(String uid) async {
    emit(state.copyWith(isLoading: true, error: null));
    final result = await _repository.getEmployerProfile(uid);
    result.fold(
      (f) => emit(state.copyWith(isLoading: false, error: f.message)),
      (emp) => emit(state.copyWith(isLoading: false, employer: emp)),
    );
  }

  Future<void> updateStudentProfile(UserModel user) async {
    emit(state.copyWith(isSaving: true, error: null));
    final result = await _repository.updateStudentProfile(user);
    result.fold(
      (f) => emit(state.copyWith(isSaving: false, error: f.message)),
      (_) => emit(state.copyWith(isSaving: false, student: user, successMessage: 'Profile updated!')),
    );
  }

  Future<void> updateEmployerProfile(EmployerModel emp) async {
    emit(state.copyWith(isSaving: true, error: null));
    final result = await _repository.updateEmployerProfile(emp);
    result.fold(
      (f) => emit(state.copyWith(isSaving: false, error: f.message)),
      (_) => emit(state.copyWith(isSaving: false, employer: emp, successMessage: 'Profile updated!')),
    );
  }

  Future<void> uploadProfileImage({required String uid, required File imageFile}) async {
    emit(state.copyWith(isSaving: true));
    final result = await _repository.uploadProfileImage(uid: uid, imageFile: imageFile);
    result.fold(
      (f) => emit(state.copyWith(isSaving: false, error: f.message)),
      (url) {
        final updated = state.student?.copyWith(photoUrl: url);
        if (updated != null) emit(state.copyWith(isSaving: false, student: updated));
      },
    );
  }

  Future<void> uploadResume({required String uid, required File resumeFile}) async {
    emit(state.copyWith(isSaving: true));
    final result = await _repository.uploadResume(uid: uid, resumeFile: resumeFile);
    result.fold(
      (f) => emit(state.copyWith(isSaving: false, error: f.message)),
      (url) {
        final updated = state.student?.copyWith(resumeUrl: url);
        if (updated != null) {
          emit(state.copyWith(isSaving: false, student: updated, successMessage: 'Resume uploaded!'));
        }
      },
    );
  }

  Future<void> uploadCompanyLogo({required String uid, required File imageFile}) async {
    emit(state.copyWith(isSaving: true));
    final result = await _repository.uploadCompanyLogo(uid: uid, imageFile: imageFile);
    result.fold(
      (f) => emit(state.copyWith(isSaving: false, error: f.message)),
      (url) {
        final updated = state.employer?.copyWith(logoUrl: url);
        if (updated != null) emit(state.copyWith(isSaving: false, employer: updated));
      },
    );
  }
}
