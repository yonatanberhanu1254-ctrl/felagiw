import 'package:dartz/dartz.dart';
import 'package:career_connect/core/error/failures.dart';

/// Base use case interface for async operations returning Either<Failure, T>.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case with no parameters.
abstract class UseCaseNoParams<Type> {
  Future<Either<Failure, Type>> call();
}

/// Use case for stream-based operations.
abstract class StreamUseCase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}

/// No parameters placeholder.
class NoParams {
  const NoParams();
}
