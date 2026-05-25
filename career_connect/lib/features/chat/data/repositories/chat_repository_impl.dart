import 'package:dartz/dartz.dart';
import 'package:career_connect/core/error/exceptions.dart';
import 'package:career_connect/core/error/failures.dart';
import 'package:career_connect/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:career_connect/features/chat/data/models/chat_model.dart';
import 'package:career_connect/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _dataSource;
  ChatRepositoryImpl({required ChatRemoteDataSource dataSource}) : _dataSource = dataSource;

  @override
  Stream<List<ChatModel>> watchUserChats(String userId) =>
      _dataSource.watchUserChats(userId);

  @override
  Stream<List<MessageModel>> watchMessages(String chatId) =>
      _dataSource.watchMessages(chatId);

  @override
  Future<Either<Failure, ChatModel>> getOrCreateChat({
    required String currentUserId,
    required String currentUserName,
    required String? currentUserPhoto,
    required String otherId,
    required String otherName,
    required String? otherPhoto,
  }) async {
    try {
      final chat = await _dataSource.getOrCreateChat(
        currentUserId: currentUserId,
        currentUserName: currentUserName,
        currentUserPhoto: currentUserPhoto,
        otherId: otherId,
        otherName: otherName,
        otherPhoto: otherPhoto,
      );
      return Right(chat);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> sendMessage(MessageModel message) async {
    try {
      await _dataSource.sendMessage(message);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> markMessagesRead({required String chatId, required String userId}) async {
    try {
      await _dataSource.markMessagesRead(chatId: chatId, currentUserId: userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
