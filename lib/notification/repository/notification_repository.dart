import 'dart:async';

import 'package:lemmy_api_client/v3.dart' hide CommentSortType;

import 'package:thunder/account/account.dart';
import 'package:thunder/core/enums/comment_sort_type.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/utils/global_context.dart';

/// Interface for a notification repository
abstract class NotificationRepository {
  /// Fetches any comment replies
  Future<GetRepliesResponse> replies({
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

  /// Dispose method to clean up resources
  void dispose();
}

/// Implementation of [InstanceRepository] using Lemmy API
class LemmyNotificationRepository implements NotificationRepository {
  /// The Lemmy client to use for the repository
  LemmyApiV3 client;

  /// Stream subscription for client changes
  StreamSubscription<LemmyApiV3>? _subscription;

  LemmyNotificationRepository({required this.client}) {
    _subscription = LemmyClient.onClientChanged.listen((newClient) => client = newClient);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  Future<GetRepliesResponse> replies({
    bool unread = false,
    int limit = 50,
    CommentSortType sort = CommentSortType.new_,
    int page = 1,
  }) async {
    final l10n = GlobalContext.l10n;
    final account = await fetchActiveProfile();
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final response = await client.run(GetReplies(
      auth: account.jwt!,
      unreadOnly: unread,
      limit: limit,
      sort: sort.toLemmyType(),
      page: page,
    ));

    return response;
  }

  @override
  Future<void> markReplyAsRead({
    required int replyId,
    bool read = true,
  }) async {
    final l10n = GlobalContext.l10n;
    final account = await fetchActiveProfile();
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    await client.run(MarkCommentReplyAsRead(
      auth: account.jwt!,
      commentReplyId: replyId,
      read: read,
    ));
  }

  @override
  Future<GetPersonMentionsResponse> mentions({
    bool unread = false,
    int limit = 50,
    CommentSortType sort = CommentSortType.new_,
    int page = 1,
  }) async {
    final l10n = GlobalContext.l10n;
    final account = await fetchActiveProfile();
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final response = await client.run(GetPersonMentions(
      auth: account.jwt!,
      unreadOnly: unread,
      limit: limit,
      sort: sort.toLemmyType(),
      page: page,
    ));

    return response;
  }

  @override
  Future<void> markMentionAsRead({
    required int mentionId,
    bool read = true,
  }) async {
    final l10n = GlobalContext.l10n;
    final account = await fetchActiveProfile();
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    await client.run(MarkPersonMentionAsRead(
      auth: account.jwt!,
      personMentionId: mentionId,
      read: read,
    ));
  }

  @override
  Future<PrivateMessagesResponse> messages({
    bool unread = false,
    int limit = 50,
    int page = 1,
  }) async {
    final l10n = GlobalContext.l10n;
    final account = await fetchActiveProfile();
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final response = await client.run(GetPrivateMessages(
      auth: account.jwt!,
      unreadOnly: unread,
      limit: limit,
      page: page,
    ));

    return response;
  }

  @override
  Future<void> markMessageAsRead({
    required int messageId,
    bool read = true,
  }) async {
    final l10n = GlobalContext.l10n;
    final account = await fetchActiveProfile();
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    await client.run(MarkPrivateMessageAsRead(
      auth: account.jwt!,
      privateMessageId: messageId,
      read: read,
    ));
  }

  @override
  Future<GetUnreadCountResponse> unreadNotificationsCount() async {
    final l10n = GlobalContext.l10n;
    final account = await fetchActiveProfile();
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final response = await client.run(GetUnreadCount(auth: account.jwt!));

    return response;
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    final l10n = GlobalContext.l10n;
    final account = await fetchActiveProfile();
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    await client.run(MarkAllAsRead(auth: account.jwt!));
  }
}
