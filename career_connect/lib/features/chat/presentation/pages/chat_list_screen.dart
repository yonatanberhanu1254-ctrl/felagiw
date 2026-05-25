import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:career_connect/core/theme/app_colors.dart';
import 'package:career_connect/core/theme/app_typography.dart';
import 'package:career_connect/core/utils/extensions.dart';
import 'package:career_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:career_connect/features/chat/data/models/chat_model.dart';
import 'package:career_connect/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:career_connect/shared/widgets/app_widgets.dart';
import 'package:career_connect/shared/widgets/skeleton_loader.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});
  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      context.read<ChatBloc>().add(WatchChats(auth.user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text('Messages', style: AppTextStyles.headlineLarge),
        actions: [
          IconButton(
              icon: const Icon(Icons.edit_outlined), onPressed: () {}),
        ],
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state.isLoading) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  const SkeletonLoader(height: 52, width: 52, borderRadius: 26),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonLoader(height: 14, width: 140),
                      SizedBox(height: 6),
                      SkeletonLoader(height: 12),
                    ],
                  )),
                ]),
              ),
            );
          }
          if (state.error != null) {
            return ErrorView(message: state.error!);
          }
          if (state.chats.isEmpty) {
            return const EmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'No conversations yet',
              subtitle:
                  'When you connect with employers,\nyour messages will appear here',
            );
          }
          final auth = context.read<AuthBloc>().state;
          final uid =
              auth is AuthAuthenticated ? auth.user.uid : '';
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.chats.length,
            itemBuilder: (ctx, i) => _ChatTile(
              chat: state.chats[i],
              currentUserId: uid,
              onTap: () => context.push(
                  '/student/chats/${state.chats[i].id}'),
            ).animate().fade(delay: (i * 50).ms).slideX(begin: 0.05),
          );
        },
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatModel chat;
  final String currentUserId;
  final VoidCallback onTap;
  const _ChatTile(
      {required this.chat,
      required this.currentUserId,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final otherName = chat.getOtherParticipantName(currentUserId);
    final otherPhoto = chat.getOtherParticipantPhoto(currentUserId);
    final hasUnread = chat.unreadCount > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: hasUnread
              ? AppColors.primary.withOpacity(isDark ? 0.06 : 0.04)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            // Avatar
            Stack(children: [
              ProfileAvatar(
                  name: otherName, imageUrl: otherPhoto, radius: 26),
              if (hasUnread)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle),
                    child: Center(
                      child: Text('${chat.unreadCount}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
            ]),
            const SizedBox(width: 14),
            // Message info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(
                        otherName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight:
                              hasUnread ? FontWeight.w700 : FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      chat.lastMessageAt.toTimeAgo(),
                      style: AppTextStyles.caption.copyWith(
                        color: hasUnread
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary),
                        fontWeight: hasUnread ? FontWeight.w600 : null,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(
                    chat.lastMessage,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: hasUnread
                          ? (isDark
                              ? AppColors.darkText
                              : AppColors.lightText)
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                      fontWeight:
                          hasUnread ? FontWeight.w600 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
