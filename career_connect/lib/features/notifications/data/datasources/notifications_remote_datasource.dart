import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:career_connect/core/config/app_config.dart';
import 'package:career_connect/core/error/exceptions.dart';
import 'package:career_connect/features/notifications/data/models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Stream<List<NotificationModel>> watchNotifications(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<void> createNotification(NotificationModel notification);
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final FirebaseFirestore _firestore;
  NotificationsRemoteDataSourceImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _firestore.collection(AppConfig.notificationsCollection);

  @override
  Stream<List<NotificationModel>> watchNotifications(String userId) {
    return _ref
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map((d) => NotificationModel.fromFirestore(d)).toList());
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try { await _ref.doc(notificationId).update({'read': true}); }
    catch (e) { throw ServerException(e.toString()); }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final snap = await _ref.where('userId', isEqualTo: userId).where('read', isEqualTo: false).get();
      for (final doc in snap.docs) { batch.update(doc.reference, {'read': true}); }
      await batch.commit();
    } catch (e) { throw ServerException(e.toString()); }
  }

  @override
  Future<void> createNotification(NotificationModel notification) async {
    try { await _ref.add(notification.toFirestore()); }
    catch (e) { throw ServerException(e.toString()); }
  }
}
