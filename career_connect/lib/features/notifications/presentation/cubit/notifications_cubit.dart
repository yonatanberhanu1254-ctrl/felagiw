import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:career_connect/features/notifications/data/models/notification_model.dart';
import 'package:career_connect/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsState extends Equatable {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final int unreadCount;
  final String? error;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.unreadCount = 0,
    this.error,
  });

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    int? unreadCount,
    String? error,
  }) => NotificationsState(
    notifications: notifications ?? this.notifications,
    isLoading: isLoading ?? this.isLoading,
    unreadCount: unreadCount ?? this.unreadCount,
    error: error,
  );

  @override
  List<Object?> get props => [notifications, isLoading, unreadCount, error];
}

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository _repository;
  NotificationsCubit({required NotificationsRepository repository})
      : _repository = repository,
        super(const NotificationsState());

  void watchNotifications(String userId) {
    emit(state.copyWith(isLoading: true));
    _repository.watchNotifications(userId).listen(
      (notifications) {
        final unread = notifications.where((n) => !n.read).length;
        emit(state.copyWith(notifications: notifications, isLoading: false, unreadCount: unread));
      },
      onError: (e) => emit(state.copyWith(isLoading: false, error: e.toString())),
    );
  }

  Future<void> markAsRead(String notificationId) async {
    await _repository.markAsRead(notificationId);
    final updated = state.notifications.map((n) =>
      n.id == notificationId ? n.copyWith(read: true) : n
    ).toList();
    emit(state.copyWith(notifications: updated, unreadCount: updated.where((n) => !n.read).length));
  }

  Future<void> markAllAsRead(String userId) async {
    await _repository.markAllAsRead(userId);
    final updated = state.notifications.map((n) => n.copyWith(read: true)).toList();
    emit(state.copyWith(notifications: updated, unreadCount: 0));
  }
}
