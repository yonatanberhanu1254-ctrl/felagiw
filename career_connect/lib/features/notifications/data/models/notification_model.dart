import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Firestore notification model.
class NotificationModel extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // 'application_update' | 'new_job' | 'message' | 'general'
  final String? referenceId; // jobId or applicationId
  final bool read;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.referenceId,
    this.read = false,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? 'general',
      referenceId: data['referenceId'],
      read: data['read'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'title': title,
        'body': body,
        'type': type,
        'referenceId': referenceId,
        'read': read,
        'createdAt': FieldValue.serverTimestamp(),
      };

  NotificationModel copyWith({bool? read}) => NotificationModel(
        id: id,
        userId: userId,
        title: title,
        body: body,
        type: type,
        referenceId: referenceId,
        read: read ?? this.read,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, userId, read];
}
