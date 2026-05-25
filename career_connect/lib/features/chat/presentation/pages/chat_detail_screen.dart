import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:career_connect/core/theme/app_colors.dart';
import 'package:career_connect/core/theme/app_typography.dart';
import 'package:career_connect/core/utils/extensions.dart';
import 'package:career_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:career_connect/features/chat/data/models/chat_model.dart';
import 'package:career_connect/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:career_connect/shared/widgets/app_widgets.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  const ChatDetailScreen({super.key, required this.chatId});
  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      context.read<ChatBloc>()
        ..add(WatchMessages(widget.chatId))
        ..add(MarkChatRead(chatId: widget.chatId, userId: auth.user.uid));
    }
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: 300.ms,
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    final msg = MessageModel(
      id: const Uuid().v4(),
      chatId: widget.chatId,
      senderId: auth.user.uid,
      senderName: auth.user.name,
      senderPhotoUrl: auth.user.photoUrl,
      text: text,
      timestamp: DateTime.now(),
    );
    context.read<ChatBloc>().add(SendMessage(msg));
    _msgCtrl.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final auth = context.read<AuthBloc>().state;
    final uid = auth is AuthAuthenticated ? auth.user.uid : '';

    return BlocConsumer<ChatBloc, ChatState>(
      listenWhen: (prev, curr) =>
          prev.messages.length != curr.messages.length,
      listener: (_, __) => _scrollToBottom(),
      builder: (context, state) {
        // Get partner name from active chat
        final chat = state.chats.where((c) => c.id == widget.chatId).firstOrNull;
        final partnerName = chat?.getOtherParticipantName(uid) ?? 'Conversation';
        final partnerPhoto = chat?.getOtherParticipantPhoto(uid);

        return Scaffold(
          backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
          appBar: AppBar(
            backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.pop(),
            ),
            title: Row(children: [
              ProfileAvatar(
                  name: partnerName, imageUrl: partnerPhoto, radius: 18),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(partnerName,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600)),
                  Text('Online',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.success)),
                ],
              ),
            ]),
            actions: [
              IconButton(
                  icon: const Icon(Icons.more_vert_rounded), onPressed: () {}),
            ],
          ),
          body: Column(
            children: [
              // Messages list
              Expanded(
                child: state.messages.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded,
                                size: 56, color: AppColors.primary),
                            SizedBox(height: 12),
                            Text('Start the conversation!'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        itemCount: state.messages.length,
                        itemBuilder: (_, i) {
                          final msg = state.messages[i];
                          final isMe = msg.senderId == uid;
                          final showAvatar = !isMe &&
                              (i == 0 ||
                                  state.messages[i - 1].senderId != msg.senderId);
                          return _MessageBubble(
                            message: msg,
                            isMe: isMe,
                            showAvatar: showAvatar,
                            partnerName: partnerName,
                            partnerPhoto: partnerPhoto,
                          ).animate().fade(duration: 200.ms);
                        },
                      ),
              ),

              // Input bar
              Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, -2))
                  ],
                ),
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 4,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkCard
                            : AppColors.lightBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  BlocBuilder<ChatBloc, ChatState>(
                    builder: (_, s) => AnimatedContainer(
                      duration: 200.ms,
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [
                          AppColors.primary,
                          AppColors.secondary
                        ]),
                        shape: BoxShape.circle,
                      ),
                      child: s.isSending
                          ? const Center(
                              child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2)))
                          : IconButton(
                              onPressed: _sendMessage,
                              icon: const Icon(Icons.send_rounded,
                                  color: Colors.white, size: 20),
                            ),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final bool showAvatar;
  final String partnerName;
  final String? partnerPhoto;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.showAvatar,
    required this.partnerName,
    this.partnerPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && showAvatar) ...[
            ProfileAvatar(
                name: partnerName, imageUrl: partnerPhoto, radius: 14),
            const SizedBox(width: 8),
          ] else if (!isMe) ...[
            const SizedBox(width: 36),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(
                      maxWidth:
                          MediaQuery.of(context).size.width * 0.72),
                  decoration: BoxDecoration(
                    gradient: isMe
                        ? const LinearGradient(colors: [
                            AppColors.primary,
                            AppColors.primaryDark
                          ])
                        : null,
                    color: isMe
                        ? null
                        : (isDark
                            ? AppColors.darkCard
                            : AppColors.lightCard),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: isMe
                          ? const Radius.circular(18)
                          : const Radius.circular(4),
                      bottomRight: isMe
                          ? const Radius.circular(4)
                          : const Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 2))
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isMe
                          ? Colors.white
                          : (isDark
                              ? AppColors.darkText
                              : AppColors.lightText),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message.timestamp.toFormattedDateTime()
                      .split('•')
                      .last
                      .trim(),
                  style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
