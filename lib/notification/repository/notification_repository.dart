import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:lemmy_api_client/v3.dart' hide CommentSortType;

import 'package:thunder/account/account.dart';
import 'package:thunder/comment/models/thunder_comment.dart';
import 'package:thunder/community/models/thunder_community.dart';
import 'package:thunder/core/data_providers/piefed_api.dart';
import 'package:thunder/core/enums/comment_sort_type.dart';
import 'package:thunder/core/enums/subscription_status.dart';
import 'package:thunder/core/enums/threadiverse_platform.dart';
import 'package:thunder/post/models/thunder_post.dart';
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
  Future<GetPersonMentionsResponse> mentions({
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
  Future<GetUnreadCountResponse> unreadNotificationsCount();

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

        final replies = response.replies
            .map((crv) => ThunderComment(
                  id: crv.comment.id,
                  creatorId: crv.creator.id,
                  postId: crv.post.id,
                  content: crv.comment.content,
                  removed: crv.comment.removed,
                  published: crv.comment.published,
                  updated: crv.comment.updated,
                  deleted: crv.comment.deleted,
                  apId: crv.comment.apId,
                  local: crv.comment.local,
                  path: crv.comment.path,
                  distinguished: crv.comment.distinguished,
                  languageId: crv.comment.languageId,
                  recipient: ThunderUser.fromLemmyUser(crv.recipient.toJson()),
                  creator: ThunderUser.fromLemmyUser(crv.creator.toJson()),
                  post: ThunderPost.fromLemmyPost(crv.post.toJson()),
                  community: ThunderCommunity.fromLemmyCommunity(crv.community.toJson()),
                  score: crv.counts.score,
                  upvotes: crv.counts.upvotes,
                  downvotes: crv.counts.downvotes,
                  childCount: crv.counts.childCount,
                  creatorBannedFromCommunity: crv.creatorBannedFromCommunity,
                  bannedFromCommunity: crv.bannedFromCommunity,
                  creatorIsModerator: crv.creatorIsModerator,
                  creatorIsAdmin: crv.creatorIsAdmin,
                  subscribed: SubscriptionStatusMapping.fromLemmyType(crv.subscribed),
                  saved: crv.saved,
                  creatorBlocked: crv.creatorBlocked,
                  myVote: crv.myVote?.toInt(),
                  read: crv.commentReply.read,
                ))
            .toList();

        return replies;
      case ThreadiversePlatform.piefed:
        // TODO: Implement action on Piefed
        throw Exception('This feature is not yet available');
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<void> markReplyAsRead({
    required int replyId,
    bool read = true,
  }) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        await client.run(MarkCommentReplyAsRead(
          auth: account.jwt!,
          commentReplyId: replyId,
          read: read,
        ));
      case ThreadiversePlatform.piefed:
        // TODO: Implement action on Piefed
        throw Exception('This feature is not yet available');
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<GetPersonMentionsResponse> mentions({
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
        return response;
      case ThreadiversePlatform.piefed:
        // TODO: Implement action on Piefed
        throw Exception('This feature is not yet available');
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<void> markMentionAsRead({
    required int mentionId,
    bool read = true,
  }) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        await client.run(MarkPersonMentionAsRead(
          auth: account.jwt!,
          personMentionId: mentionId,
          read: read,
        ));
      case ThreadiversePlatform.piefed:
        // TODO: Implement action on Piefed
        throw Exception('This feature is not yet available');
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
  Future<void> markMessageAsRead({
    required int messageId,
    bool read = true,
  }) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        await client.run(MarkPrivateMessageAsRead(
          auth: account.jwt!,
          privateMessageId: messageId,
          read: read,
        ));
      case ThreadiversePlatform.piefed:
        // TODO: Implement action on Piefed
        throw Exception('This feature is not yet available');
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<GetUnreadCountResponse> unreadNotificationsCount() async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await client.run(GetUnreadCount(auth: account.jwt!));
        return response;
      case ThreadiversePlatform.piefed:
        // TODO: Implement action on Piefed
        throw Exception('This feature is not yet available');
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
        // TODO: Implement action on Piefed
        throw Exception('This feature is not yet available');
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }
}
