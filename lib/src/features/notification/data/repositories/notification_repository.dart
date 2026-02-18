import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:thunder/src/foundation/contracts/contracts.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/foundation/networking/networking.dart';
import 'package:thunder/src/features/notification/domain/models/unread_notifications_count.dart';

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
  Future<UnreadNotificationsCount> unreadNotificationsCount();

  /// Marks all notifications as read
  Future<void> markAllNotificationsAsRead();
}

/// Implementation of [NotificationRepository]
class NotificationRepositoryImpl implements NotificationRepository {
  /// The account to use for methods invoked in this repository
  final Account account;

  /// The API client to use for the repository
  final ThunderApiClient _api;

  /// The localization service to use for user-facing errors
  final LocalizationService _localizationService;

  /// Creates a new NotificationRepositoryImpl.
  ///
  /// An optional [api] client can be provided for testing.
  NotificationRepositoryImpl({
    required this.account,
    ThunderApiClient? api,
    LocalizationService localizationService = const GlobalContextLocalizationService(),
  })  : _api = api ?? ApiClientFactory.create(account, debug: kDebugMode),
        _localizationService = localizationService;

  @override
  Future<List<ThunderComment>> replies({
    bool unread = false,
    int limit = 50,
    CommentSortType sort = CommentSortType.new_,
    int page = 1,
  }) async {
    if (account.anonymous) {
      throw Exception(_localizationService.l10n.userNotLoggedIn);
    }
    return await _api.getCommentReplies(page: page, limit: limit, sort: sort, unread: unread);
  }

  @override
  Future<void> markReplyAsRead({required int replyId, bool read = true}) async {
    final l10n = _localizationService.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    await _api.markCommentReplyAsRead(replyId: replyId, read: read);
  }

  @override
  Future<List<ThunderComment>> mentions({
    bool unread = false,
    int limit = 50,
    CommentSortType sort = CommentSortType.new_,
    int page = 1,
  }) async {
    final l10n = _localizationService.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    return await _api.getCommentMentions(page: page, limit: limit, sort: sort, unread: unread);
  }

  @override
  Future<void> markMentionAsRead({required int mentionId, bool read = true}) async {
    final l10n = _localizationService.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    await _api.markCommentMentionAsRead(mentionId: mentionId, read: read);
  }

  @override
  Future<List<ThunderPrivateMessage>> messages({
    bool unread = false,
    int limit = 50,
    int page = 1,
  }) async {
    final l10n = _localizationService.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    return await _api.getPrivateMessages(page: page, limit: limit, unread: unread);
  }

  @override
  Future<void> markMessageAsRead({required int messageId, bool read = true}) async {
    final l10n = _localizationService.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    await _api.markPrivateMessageAsRead(messageId: messageId, read: read);
  }

  @override
  Future<UnreadNotificationsCount> unreadNotificationsCount() async {
    final l10n = _localizationService.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final response = await _api.unreadCount();
    return UnreadNotificationsCount(
      replies: response.replies,
      mentions: response.mentions,
      privateMessages: response.privateMessages,
    );
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    final l10n = _localizationService.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    await _api.markAllNotificationsAsRead();
  }
}
