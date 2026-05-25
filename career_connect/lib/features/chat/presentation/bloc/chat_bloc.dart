import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:career_connect/features/chat/data/models/chat_model.dart';
import 'package:career_connect/features/chat/domain/repositories/chat_repository.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class ChatState extends Equatable {
  final List<ChatModel> chats;
  final List<MessageModel> messages;
  final bool isLoading;
  final bool isSending;
  final String? error;
  final String? activeChatId;

  const ChatState({
    this.chats = const [],
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
    this.activeChatId,
  });

  ChatState copyWith({
    List<ChatModel>? chats,
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
    String? activeChatId,
  }) =>
      ChatState(
        chats: chats ?? this.chats,
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        isSending: isSending ?? this.isSending,
        error: error,
        activeChatId: activeChatId ?? this.activeChatId,
      );

  @override
  List<Object?> get props => [chats, messages, isLoading, isSending, error, activeChatId];
}

// ── Events ────────────────────────────────────────────────────────────────────

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class WatchChats extends ChatEvent {
  final String userId;
  const WatchChats(this.userId);
}

class WatchMessages extends ChatEvent {
  final String chatId;
  const WatchMessages(this.chatId);
}

class SendMessage extends ChatEvent {
  final MessageModel message;
  const SendMessage(this.message);
  @override
  List<Object> get props => [message];
}

class ChatsUpdated extends ChatEvent {
  final List<ChatModel> chats;
  const ChatsUpdated(this.chats);
}

class MessagesUpdated extends ChatEvent {
  final List<MessageModel> messages;
  const MessagesUpdated(this.messages);
}

class MarkChatRead extends ChatEvent {
  final String chatId;
  final String userId;
  const MarkChatRead({required this.chatId, required this.userId});
}

// ── Bloc ──────────────────────────────────────────────────────────────────────

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;

  ChatBloc({required ChatRepository repository})
      : _repository = repository,
        super(const ChatState()) {
    on<WatchChats>(_onWatchChats);
    on<WatchMessages>(_onWatchMessages);
    on<SendMessage>(_onSendMessage);
    on<ChatsUpdated>(_onChatsUpdated);
    on<MessagesUpdated>(_onMessagesUpdated);
    on<MarkChatRead>(_onMarkRead);
  }

  void _onWatchChats(WatchChats event, Emitter<ChatState> emit) {
    emit(state.copyWith(isLoading: true));
    emit.forEach(
      _repository.watchUserChats(event.userId),
      onData: (chats) => state.copyWith(chats: chats, isLoading: false),
      onError: (_, __) => state.copyWith(isLoading: false, error: 'Failed to load chats'),
    );
  }

  void _onWatchMessages(WatchMessages event, Emitter<ChatState> emit) {
    emit(state.copyWith(activeChatId: event.chatId));
    emit.forEach(
      _repository.watchMessages(event.chatId),
      onData: (messages) => state.copyWith(messages: messages),
      onError: (_, __) => state.copyWith(error: 'Failed to load messages'),
    );
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    emit(state.copyWith(isSending: true));
    final result = await _repository.sendMessage(event.message);
    result.fold(
      (f) => emit(state.copyWith(isSending: false, error: f.message)),
      (_) => emit(state.copyWith(isSending: false)),
    );
  }

  void _onChatsUpdated(ChatsUpdated event, Emitter<ChatState> emit) {
    emit(state.copyWith(chats: event.chats));
  }

  void _onMessagesUpdated(MessagesUpdated event, Emitter<ChatState> emit) {
    emit(state.copyWith(messages: event.messages));
  }

  Future<void> _onMarkRead(MarkChatRead event, Emitter<ChatState> emit) async {
    await _repository.markMessagesRead(chatId: event.chatId, userId: event.userId);
  }
}
