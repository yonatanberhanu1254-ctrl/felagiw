import 'package:dartz/dartz.dart';
import 'package:career_connect/core/error/exceptions.dart';
import 'package:career_connect/core/error/failures.dart';
import 'package:career_connect/features/auth/data/models/employer_model.dart';
import 'package:career_connect/features/employer/data/datasources/employer_remote_datasource.dart';
import 'package:career_connect/features/employer/domain/repositories/employer_repository.dart';

class EmployerRepositoryImpl implements EmployerRepository {
  final EmployerRemoteDataSource _dataSource;

  EmployerRepositoryImpl({required EmployerRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Either<Failure, EmployerModel>> getEmployerProfile(String uid) async {
    try {
      final employer = await _dataSource.getEmployerProfile(uid);
      return Right(employer);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateEmployerProfile(EmployerModel employer) async {
    try {
      await _dataSource.updateEmployerProfile(employer);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadCompanyLogo({
    required String uid,
    required String filePath,
  }) async {
    try {
      final url = await _dataSource.uploadCompanyLogo(uid: uid, filePath: filePath);
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
