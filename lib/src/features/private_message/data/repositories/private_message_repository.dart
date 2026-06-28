import 'package:flutter/foundation.dart';

import 'package:thunder/src/foundation/foundation.dart';

/// Repository contract for direct-message reads, writes, and read state.
abstract class PrivateMessageRepository {
  /// Fetches private messages for the inbox.
  Future<List<ThunderPrivateMessage>> messages({
    bool unread,
    int limit,
    int page,
  });

  /// Fetches messages exchanged with a single person.
  Future<List<ThunderPrivateMessage>> conversation({
    required int personId,
    int? conversationId,
    int page,
    int limit,
  });

  /// Sends a direct message to a recipient.
  Future<ThunderPrivateMessage> create({
    required int recipientId,
    required String content,
  });

  /// Updates the read state for a private message.
  Future<void> markAsRead({
    required int notificationId,
    bool read,
  });
}

/// Implementation of [PrivateMessageRepository] using the unified API client
class PrivateMessageRepositoryImpl implements PrivateMessageRepository {
  /// The account to use for methods invoked in this repository
  final Account account;

  /// The API client to use for the repository
  final ThunderApiClient _api;

  /// The localization service to use for user-facing errors
  final LocalizationService _localization;

  /// Creates a new PrivateMessageRepositoryImpl.
  ///
  /// An optional [api] client and [localization] can be provided for testing.
  PrivateMessageRepositoryImpl({
    required this.account,
    ThunderApiClient? api,
    LocalizationService localization = const ThunderLocalizationService(),
  })  : _api = api ?? ApiClientFactory.create(account, debug: kDebugMode),
        _localization = localization;

  @override
  Future<List<ThunderPrivateMessage>> messages({
    bool unread = false,
    int limit = 50,
    int page = 1,
  }) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    return _api.getPrivateMessages(page: page, limit: limit, unread: unread);
  }

  @override
  Future<List<ThunderPrivateMessage>> conversation({
    required int personId,
    int? conversationId,
    int page = 1,
    int limit = 50,
  }) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    return _api.getPrivateMessageConversation(
      personId: personId,
      conversationId: conversationId,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<ThunderPrivateMessage> create({
    required int recipientId,
    required String content,
  }) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    return _api.createPrivateMessage(recipientId: recipientId, content: content);
  }

  @override
  Future<void> markAsRead({
    required int notificationId,
    bool read = true,
  }) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    await _api.markPrivateMessageAsRead(notificationId: notificationId, read: read);
  }
}
