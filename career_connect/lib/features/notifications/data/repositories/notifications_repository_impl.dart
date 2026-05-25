import 'package:dartz/dartz.dart';
import 'package:career_connect/core/error/exceptions.dart';
import 'package:career_connect/core/error/failures.dart';
import 'package:career_connect/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:career_connect/features/notifications/data/models/notification_model.dart';
import 'package:career_connect/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource _dataSource;
  NotificationsRepositoryImpl({required NotificationsRemoteDataSource dataSource}) : _dataSource = dataSource;

  @override
  Stream<List<NotificationModel>> watchNotifications(String userId) =>
      _dataSource.watchNotifications(userId);

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try { await _dataSource.markAsRead(notificationId); return const Right(null); }
    on ServerException catch (e) { return Left(ServerFailure(e.message)); }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead(String userId) async {
    try { await _dataSource.markAllAsRead(userId); return const Right(null); }
    on ServerException catch (e) { return Left(ServerFailure(e.message)); }
  }
}
