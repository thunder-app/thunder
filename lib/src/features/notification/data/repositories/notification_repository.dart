import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:thunder/src/core/cache/platform_version_cache.dart';
import 'package:thunder/src/core/models/thunder_private_message.dart';
import 'package:thunder/src/core/network/lemmy_api.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/core/network/piefed_api.dart';
import 'package:thunder/src/core/enums/comment_sort_type.dart';
import 'package:thunder/src/core/enums/threadiverse_platform.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/app/utils/global_context.dart';

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
  Future<List<ThunderPrivateMessage>> messages({
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
  late LemmyApi lemmy;

  /// The Piefed client to use for the repository
  late PiefedApi piefed;

  NotificationRepositoryImpl({required this.account}) {
    final version = PlatformVersionCache().get(account.instance);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        lemmy = LemmyApi(account: account, debug: kDebugMode, version: version);
        break;
      case ThreadiversePlatform.piefed:
        piefed = PiefedApi(account: account, debug: kDebugMode, version: version);
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
    if (account.anonymous) throw Exception(GlobalContext.l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await lemmy.getCommentReplies(page: page, limit: limit, sort: sort, unread: unread);

        final replies = response['replies'].map<ThunderComment>((crv) {
          final comment = ThunderComment.fromLemmyCommentView(crv);

          return comment.copyWith(
            recipient: ThunderUser.fromLemmyUser(crv['recipient']),
            replyMentionId: crv['comment_reply']['id'],
            read: crv['comment_reply']['read'],
          );
        }).toList();
        return replies;
      case ThreadiversePlatform.piefed:
        final response = await piefed.getCommentReplies(page: page, limit: limit, sort: sort, unread: unread);
        return response['replies'].map<ThunderComment>((crv) {
          final comment = ThunderComment.fromPiefedCommentView(crv);

          return comment.copyWith(
            recipient: ThunderUser.fromPiefedUser(crv['recipient']),
            replyMentionId: crv['comment_reply']['id'],
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
        await lemmy.markCommentReplyAsRead(replyId: replyId, read: read);
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
    if (account.anonymous) throw Exception(GlobalContext.l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await lemmy.getCommentMentions(page: page, limit: limit, sort: sort, unread: unread);

        return response['mentions'].map<ThunderComment>((mention) {
          final comment = ThunderComment.fromLemmyCommentView(mention);

          return comment.copyWith(
            recipient: ThunderUser.fromLemmyUser(mention['recipient']),
            replyMentionId: mention['person_mention']['id'],
            read: mention['person_mention']['read'],
          );
        }).toList();
      case ThreadiversePlatform.piefed:
        final response = await piefed.getCommentMentions(page: page, limit: limit, sort: sort, unread: unread);

        return response['replies'].map<ThunderComment>((mention) {
          final comment = ThunderComment.fromPiefedCommentView(mention);

          return comment.copyWith(
            recipient: ThunderUser.fromPiefedUser(mention['recipient']),
            replyMentionId: mention['comment_reply']['id'],
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
        await lemmy.markCommentMentionAsRead(mentionId: mentionId, read: read);
      case ThreadiversePlatform.piefed:
        await piefed.markCommentReplyAsRead(replyId: mentionId, read: read);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<List<ThunderPrivateMessage>> messages({
    bool unread = false,
    int limit = 50,
    int page = 1,
  }) async {
    if (account.anonymous) throw Exception(GlobalContext.l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await lemmy.getPrivateMessages(page: page, limit: limit, unread: unread);
      case ThreadiversePlatform.piefed:
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
        await lemmy.markPrivateMessageAsRead(messageId: messageId, read: read);
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
        return await lemmy.unreadCount();
      case ThreadiversePlatform.piefed:
        return await piefed.unreadCount();
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
        await lemmy.markAllNotificationsAsRead();
      case ThreadiversePlatform.piefed:
        await piefed.markAllNotificationsAsRead();
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }
}
