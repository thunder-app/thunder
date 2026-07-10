import 'package:thunder/src/core/core.dart';
import 'package:thunder/src/core/networking/resolved_api_client.dart';

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
  final ResolvedApiClient _api;

  /// The localization service to use for user-facing errors
  final LocalizationService _localization;

  /// Creates a new PrivateMessageRepositoryImpl.
  ///
  /// An optional [api] client and [localization] can be provided for testing.
  PrivateMessageRepositoryImpl({
    required this.account,
    ThunderApiClient? api,
    LocalizationService localization = const ThunderLocalizationService(),
  })  : _api = ResolvedApiClient(account: account, api: api),
        _localization = localization;

  @override
  Future<List<ThunderPrivateMessage>> messages({
    bool unread = false,
    int limit = 50,
    int page = 1,
  }) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    return api.getPrivateMessages(page: page, limit: limit, unread: unread);
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

    final api = await _api.get();
    return api.getPrivateMessageConversation(
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

    final api = await _api.get();
    return api.createPrivateMessage(recipientId: recipientId, content: content);
  }

  @override
  Future<void> markAsRead({
    required int notificationId,
    bool read = true,
  }) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    await api.markPrivateMessageAsRead(notificationId: notificationId, read: read);
  }
}
