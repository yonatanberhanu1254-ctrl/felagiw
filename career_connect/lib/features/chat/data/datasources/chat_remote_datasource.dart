import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:career_connect/core/config/app_config.dart';
import 'package:career_connect/core/error/exceptions.dart';
import 'package:career_connect/features/chat/data/models/chat_model.dart';

abstract class ChatRemoteDataSource {
  Stream<List<ChatModel>> watchUserChats(String userId);
  Stream<List<MessageModel>> watchMessages(String chatId);
  Future<ChatModel> getOrCreateChat({required String currentUserId, required String currentUserName, required String? currentUserPhoto, required String otherId, required String otherName, required String? otherPhoto});
  Future<void> sendMessage(MessageModel message);
  Future<void> markMessagesRead({required String chatId, required String currentUserId});
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore _firestore;

  ChatRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Stream<List<ChatModel>> watchUserChats(String userId) {
    return _firestore
        .collection(AppConfig.chatsCollection)
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => ChatModel.fromFirestore(doc)).toList());
  }

  @override
  Stream<List<MessageModel>> watchMessages(String chatId) {
    return _firestore
        .collection(AppConfig.chatsCollection)
        .doc(chatId)
        .collection(AppConfig.messagesCollection)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => MessageModel.fromFirestore(doc)).toList());
  }

  @override
  Future<ChatModel> getOrCreateChat({
    required String currentUserId,
    required String currentUserName,
    required String? currentUserPhoto,
    required String otherId,
    required String otherName,
    required String? otherPhoto,
  }) async {
    try {
      // Check if chat already exists
      final existing = await _firestore
          .collection(AppConfig.chatsCollection)
          .where('participantIds', arrayContains: currentUserId)
          .get();

      for (final doc in existing.docs) {
        final chat = ChatModel.fromFirestore(doc);
        if (chat.participantIds.contains(otherId)) return chat;
      }

      // Create new chat
      final chatData = ChatModel(
        id: '',
        participantIds: [currentUserId, otherId],
        participantNames: {currentUserId: currentUserName, otherId: otherName},
        participantPhotos: {currentUserId: currentUserPhoto, otherId: otherPhoto},
        lastMessage: '',
        lastSenderId: '',
        lastMessageAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection(AppConfig.chatsCollection)
          .add(chatData.toFirestore());

      final doc = await docRef.get();
      return ChatModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendMessage(MessageModel message) async {
    try {
      final batch = _firestore.batch();

      // Add message to subcollection
      final msgRef = _firestore
          .collection(AppConfig.chatsCollection)
          .doc(message.chatId)
          .collection(AppConfig.messagesCollection)
          .doc();

      batch.set(msgRef, message.toFirestore());

      // Update chat thread metadata
      final chatRef = _firestore.collection(AppConfig.chatsCollection).doc(message.chatId);
      batch.update(chatRef, {
        'lastMessage': message.text,
        'lastSenderId': message.senderId,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'unreadCount': FieldValue.increment(1),
      });

      await batch.commit();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markMessagesRead({required String chatId, required String currentUserId}) async {
    try {
      await _firestore.collection(AppConfig.chatsCollection).doc(chatId).update({
        'unreadCount': 0,
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
