import 'package:dartz/dartz.dart';
import 'package:career_connect/core/error/failures.dart';
import 'package:career_connect/features/notifications/data/models/notification_model.dart';

abstract class NotificationsRepository {
  Stream<List<NotificationModel>> watchNotifications(String userId);
  Future<Either<Failure, void>> markAsRead(String notificationId);
  Future<Either<Failure, void>> markAllAsRead(String userId);
}
