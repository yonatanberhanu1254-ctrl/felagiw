import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:career_connect/core/error/exceptions.dart';
import 'package:career_connect/core/error/failures.dart';
import 'package:career_connect/features/auth/data/models/employer_model.dart';
import 'package:career_connect/features/auth/data/models/user_model.dart';
import 'package:career_connect/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:career_connect/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _dataSource;
  ProfileRepositoryImpl({required ProfileRemoteDataSource dataSource}) : _dataSource = dataSource;

  @override
  Future<Either<Failure, UserModel>> getStudentProfile(String uid) async {
    try {
      return Right(await _dataSource.getStudentProfile(uid));
    } on NotFoundException catch (e) { return Left(NotFoundFailure(e.message)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message)); }
  }

  @override
  Future<Either<Failure, void>> updateStudentProfile(UserModel user) async {
    try { await _dataSource.updateStudentProfile(user); return const Right(null); }
    on ServerException catch (e) { return Left(ServerFailure(e.message)); }
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage({required String uid, required File imageFile}) async {
    try { return Right(await _dataSource.uploadProfileImage(uid: uid, imageFile: imageFile)); }
    on StorageException catch (e) { return Left(StorageFailure(e.message)); }
  }

  @override
  Future<Either<Failure, String>> uploadResume({required String uid, required File resumeFile}) async {
    try { return Right(await _dataSource.uploadResume(uid: uid, resumeFile: resumeFile)); }
    on StorageException catch (e) { return Left(StorageFailure(e.message)); }
  }

  @override
  Future<Either<Failure, EmployerModel>> getEmployerProfile(String uid) async {
    try { return Right(await _dataSource.getEmployerProfile(uid)); }
    on NotFoundException catch (e) { return Left(NotFoundFailure(e.message)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message)); }
  }

  @override
  Future<Either<Failure, void>> updateEmployerProfile(EmployerModel employer) async {
    try { await _dataSource.updateEmployerProfile(employer); return const Right(null); }
    on ServerException catch (e) { return Left(ServerFailure(e.message)); }
  }

  @override
  Future<Either<Failure, String>> uploadCompanyLogo({required String uid, required File imageFile}) async {
    try { return Right(await _dataSource.uploadCompanyLogo(uid: uid, imageFile: imageFile)); }
    on StorageException catch (e) { return Left(StorageFailure(e.message)); }
  }
}
