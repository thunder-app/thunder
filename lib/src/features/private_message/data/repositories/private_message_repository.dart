import 'package:flutter/foundation.dart';

import 'package:thunder/src/foundation/contracts/contracts.dart';
import 'package:thunder/src/foundation/networking/networking.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';

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

/// API-backed implementation of [PrivateMessageRepository].
class PrivateMessageRepositoryImpl implements PrivateMessageRepository {
  /// Creates a repository for [account].
  PrivateMessageRepositoryImpl({
    required this.account,
    ThunderApiClient? api,
    LocalizationService localizationService = const GlobalContextLocalizationService(),
  })  : _api = api ?? ApiClientFactory.create(account, debug: kDebugMode),
        _localizationService = localizationService;

  /// Account used to authenticate private-message requests.
  final Account account;
  final ThunderApiClient _api;
  final LocalizationService _localizationService;

  void _ensureLoggedIn() {
    if (account.anonymous) {
      throw Exception(_localizationService.l10n.userNotLoggedIn);
    }
  }

  @override
  Future<List<ThunderPrivateMessage>> messages({
    bool unread = false,
    int limit = 50,
    int page = 1,
  }) async {
    _ensureLoggedIn();
    return _api.getPrivateMessages(page: page, limit: limit, unread: unread);
  }

  @override
  Future<List<ThunderPrivateMessage>> conversation({
    required int personId,
    int? conversationId,
    int page = 1,
    int limit = 50,
  }) async {
    _ensureLoggedIn();
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
    _ensureLoggedIn();
    return _api.createPrivateMessage(recipientId: recipientId, content: content);
  }

  @override
  Future<void> markAsRead({
    required int notificationId,
    bool read = true,
  }) async {
    _ensureLoggedIn();
    await _api.markPrivateMessageAsRead(notificationId: notificationId, read: read);
  }
}
