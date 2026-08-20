import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/core/config/config.dart';
import 'package:thunder/src/core/services/services.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/inbox/inbox.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/src/core/app/repository_factories.dart';

/// A page for displaying notifications (replies, mentions, or messages).
class NotificationsPage extends StatelessWidget {
  /// The type of inbox notification to display.
  final InboxType inboxType;

  /// The list of comments (used for replies and mentions).
  final List<ThunderComment> comments;

  /// The list of private messages (used for messages).
  final List<ThunderPrivateMessage> messages;

  const NotificationsPage({super.key, required this.inboxType, this.comments = const [], this.messages = const []});

  factory NotificationsPage.replies({Key? key, required List<ThunderComment> replies}) {
    return NotificationsPage(key: key, inboxType: InboxType.replies, comments: replies);
  }

  factory NotificationsPage.mentions({Key? key, required List<ThunderComment> mentions}) {
    return NotificationsPage(key: key, inboxType: InboxType.mentions, comments: mentions);
  }

  factory NotificationsPage.messages({Key? key, required List<ThunderPrivateMessage> messages}) {
    return NotificationsPage(key: key, inboxType: InboxType.messages, messages: messages);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = GlobalContext.l10n;

    final account = context.select<ProfileBloc, Account>((bloc) => bloc.state.account);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: inboxType == InboxType.messages
              ? (InboxBloc(
                  account: account,
                  commentRepository: createCommentRepository(account),
                  notificationRepository: createNotificationRepository(account),
                  privateMessageRepository: createPrivateMessageRepository(account),
                  localizationService: const ThunderLocalizationService(),
                )..add(const GetInboxEvent(reset: true, inboxType: InboxType.messages)))
              : InboxBloc.initWith(
                  account: account,
                  replies: comments,
                  showUnreadOnly: true,
                  commentRepository: createCommentRepository(account),
                  notificationRepository: createNotificationRepository(account),
                  privateMessageRepository: createPrivateMessageRepository(account),
                  localizationService: const ThunderLocalizationService(),
                ),
        ),
        BlocProvider.value(
          value: PostBloc(
            account: account,
            postRepository: createPostRepository(account),
            commentRepository: createCommentRepository(account),
            communityRepository: createCommunityRepository(account),
            preferencesStore: const UserPreferencesStore(),
            localizationService: const ThunderLocalizationService(),
          ),
        ),
      ],
      child: BlocConsumer<InboxBloc, InboxState>(
        listener: (BuildContext context, InboxState state) {
          final shouldPop = switch (inboxType) {
            InboxType.replies => state.replies.isEmpty,
            InboxType.mentions => state.replies.isEmpty,
            InboxType.messages => state.privateMessages.isEmpty && state.status == InboxStatus.success,
            InboxType.all => false,
          };

          if (shouldPop && (ModalRoute.of(context)?.isCurrent ?? false)) {
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          final subtitle = switch (inboxType) {
            InboxType.replies => l10n.reply(comments.length),
            InboxType.mentions => l10n.mention(comments.length),
            InboxType.messages => l10n.message(messages.length),
            InboxType.all => '',
          };

          final body = switch (inboxType) {
            InboxType.replies => InboxRepliesView(replies: state.replies),
            InboxType.mentions => InboxMentionsView(mentions: state.replies),
            InboxType.messages => InboxPrivateMessagesView(privateMessages: state.privateMessages.isEmpty ? messages : state.privateMessages),
            InboxType.all => const SizedBox.shrink(),
          };

          return Material(
            child: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                    sliver: SliverAppBar(
                      pinned: true,
                      centerTitle: false,
                      toolbarHeight: APP_BAR_HEIGHT,
                      forceElevated: innerBoxIsScrolled,
                      title: ListTile(
                        title: Text(l10n.inbox, style: theme.textTheme.titleLarge),
                        subtitle: Text(subtitle),
                      ),
                    ),
                  ),
                ];
              },
              body: body,
            ),
          );
        },
      ),
    );
  }
}
