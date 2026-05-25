import 'package:dartz/dartz.dart';
import 'package:career_connect/core/error/failures.dart';
import 'package:career_connect/features/chat/data/models/chat_model.dart';

abstract class ChatRepository {
  Stream<List<ChatModel>> watchUserChats(String userId);
  Stream<List<MessageModel>> watchMessages(String chatId);
  Future<Either<Failure, ChatModel>> getOrCreateChat({
    required String currentUserId,
    required String currentUserName,
    required String? currentUserPhoto,
    required String otherId,
    required String otherName,
    required String? otherPhoto,
  });
  Future<Either<Failure, void>> sendMessage(MessageModel message);
  Future<Either<Failure, void>> markMessagesRead({required String chatId, required String userId});
}
