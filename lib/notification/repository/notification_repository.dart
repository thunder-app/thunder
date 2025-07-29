import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:lemmy_api_client/v3.dart' hide CommentSortType;

import 'package:thunder/account/account.dart';
import 'package:thunder/comment/models/thunder_comment.dart';
import 'package:thunder/core/data_providers/piefed_api.dart';
import 'package:thunder/core/enums/comment_sort_type.dart';
import 'package:thunder/core/enums/threadiverse_platform.dart';
import 'package:thunder/user/models/thunder_user.dart';
import 'package:thunder/utils/global_context.dart';

/// Interface for a notification repository
abstract class NotificationRepository {
  /// Fetches any comment replies
  Future<List<ThunderComment>> replies({
    bool unread,
    int limit,
    CommentSortType sort,
    int page,
  });

  /// Marks a comment reply as read
  Future<void> markReplyAsRead({
    required int replyId,
    bool read = true,
  });

  /// Fetches any comment mentions
  Future<List<ThunderComment>> mentions({
    bool unread,
    int limit,
    CommentSortType sort,
    int page,
  });

  /// Marks a comment mention as read
  Future<void> markMentionAsRead({
    required int mentionId,
    bool read = true,
  });

  /// Fetches any private messages
  Future<PrivateMessagesResponse> messages({
    bool unread,
    int limit,
    int page,
  });

  /// Marks a private message as read
  Future<void> markMessageAsRead({
    required int messageId,
    bool read = true,
  });

  /// Fetches number of unread notifications
  Future<Map<String, dynamic>> unreadNotificationsCount();

  /// Marks all notifications as read
  Future<void> markAllNotificationsAsRead();
}

/// Implementation of [InstanceRepository]
class NotificationRepositoryImpl implements NotificationRepository {
  /// The account to use for methods invoked in this repository
  Account account;

  /// The Lemmy client to use for the repository
  late LemmyApiV3 client;

  /// The Piefed client to use for the repository
  late PiefedApi piefed;

  NotificationRepositoryImpl({required this.account}) {
    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        client = LemmyApiV3(account.instance, debug: kDebugMode);
        break;
      case ThreadiversePlatform.piefed:
        piefed = PiefedApi(account: account, debug: kDebugMode);
        break;
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<List<ThunderComment>> replies({
    bool unread = false,
    int limit = 50,
    CommentSortType sort = CommentSortType.new_,
    int page = 1,
  }) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await client.run(GetReplies(
          auth: account.jwt!,
          unreadOnly: unread,
          limit: limit,
          sort: sort.toLemmyType(),
          page: page,
        ));

        final replies = response.replies.map((crv) {
          final comment = ThunderComment.fromLemmyCommentView(crv.toJson());

          return comment.copyWith(
            recipient: ThunderUser.fromLemmyUser(crv.recipient.toJson()),
            read: crv.commentReply.read,
          );
        }).toList();
        return replies;
      case ThreadiversePlatform.piefed:
        final response = await piefed.getCommentReplies(page: page, limit: limit, sort: sort, unread: unread);
        return response['replies'].map<ThunderComment>((crv) {
          final comment = ThunderComment.fromPiefedCommentView(crv);

          return comment.copyWith(
            recipient: ThunderUser.fromPiefedUser(crv['recipient']),
            read: crv['comment_reply']['read'],
          );
        }).toList();
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<void> markReplyAsRead({required int replyId, bool read = true}) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        await client.run(MarkCommentReplyAsRead(auth: account.jwt!, commentReplyId: replyId, read: read));
      case ThreadiversePlatform.piefed:
        await piefed.markCommentReplyAsRead(replyId: replyId, read: read);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<List<ThunderComment>> mentions({
    bool unread = false,
    int limit = 50,
    CommentSortType sort = CommentSortType.new_,
    int page = 1,
  }) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await client.run(GetPersonMentions(
          auth: account.jwt!,
          unreadOnly: unread,
          limit: limit,
          sort: sort.toLemmyType(),
          page: page,
        ));
        return response.mentions.map((mention) {
          final comment = ThunderComment.fromLemmyCommentView(mention.toJson());

          return comment.copyWith(
            recipient: ThunderUser.fromLemmyUser(mention.recipient.toJson()),
            read: mention.personMention.read,
          );
        }).toList();
      case ThreadiversePlatform.piefed:
        final response = await piefed.getCommentMentions(page: page, limit: limit, sort: sort, unread: unread);
        return response['replies'].map<ThunderComment>((mention) {
          final comment = ThunderComment.fromPiefedCommentView(mention);

          return comment.copyWith(
            recipient: ThunderUser.fromPiefedUser(mention['recipient']),
            read: mention['comment_reply']['read'],
          );
        }).toList();
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<void> markMentionAsRead({required int mentionId, bool read = true}) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        await client.run(MarkPersonMentionAsRead(auth: account.jwt!, personMentionId: mentionId, read: read));
      case ThreadiversePlatform.piefed:
        await piefed.markCommentReplyAsRead(replyId: mentionId, read: read);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<PrivateMessagesResponse> messages({
    bool unread = false,
    int limit = 50,
    int page = 1,
  }) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await client.run(GetPrivateMessages(
          auth: account.jwt!,
          unreadOnly: unread,
          limit: limit,
          page: page,
        ));
        return response;
      case ThreadiversePlatform.piefed:
        // TODO: Implement action on Piefed
        throw Exception('This feature is not yet available');
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<void> markMessageAsRead({required int messageId, bool read = true}) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        await client.run(MarkPrivateMessageAsRead(auth: account.jwt!, privateMessageId: messageId, read: read));
      case ThreadiversePlatform.piefed:
        await piefed.markPrivateMessageAsRead(messageId: messageId, read: read);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<Map<String, dynamic>> unreadNotificationsCount() async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await client.run(GetUnreadCount(auth: account.jwt!));
        return response.toJson();
      case ThreadiversePlatform.piefed:
        final response = await piefed.unreadCount();
        return response;
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        await client.run(MarkAllAsRead(auth: account.jwt!));
      case ThreadiversePlatform.piefed:
        await piefed.markAllNotificationsAsRead();
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }
}
