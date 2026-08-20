import 'package:thunder/src/core/core.dart';
import 'package:thunder/src/core/networking/resolved_api_client.dart';
import 'package:thunder/src/features/notification/domain/models/unread_notifications_count.dart';

/// Repository contract for notification inbox reads and read state.
abstract class NotificationRepository {
  /// Fetches any comment replies
  Future<List<ThunderComment>> replies({bool unread, int limit, CommentSortType sort, int page});

  /// Marks a comment reply as read
  Future<void> markReplyAsRead({required int replyId, bool read = true});

  /// Fetches any comment mentions
  Future<List<ThunderComment>> mentions({bool unread, int limit, CommentSortType sort, int page});

  /// Marks a comment mention as read
  Future<void> markMentionAsRead({required int mentionId, bool read = true});

  /// Fetches number of unread notifications
  Future<UnreadNotificationsCount> unreadNotificationsCount();

  /// Marks all notifications as read
  Future<void> markAllNotificationsAsRead();
}

/// Implementation of [NotificationRepository] using the unified API client
class NotificationRepositoryImpl implements NotificationRepository {
  /// The account to use for methods invoked in this repository
  final Account account;

  /// The API client to use for the repository
  final ResolvedApiClient _api;

  /// The localization service to use for user-facing errors
  final LocalizationService _localization;

  /// Creates a new NotificationRepositoryImpl.
  ///
  /// An optional [api] client and [localization] can be provided for testing.
  NotificationRepositoryImpl({required this.account, ThunderApiClient? api, LocalizationService localization = const ThunderLocalizationService()})
    : _api = ResolvedApiClient(account: account, api: api),
      _localization = localization;

  @override
  Future<List<ThunderComment>> replies({bool unread = false, int limit = 50, CommentSortType sort = CommentSortType.new_, int page = 1}) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    return api.getCommentReplies(page: page, limit: limit, sort: sort, unread: unread);
  }

  @override
  Future<void> markReplyAsRead({required int replyId, bool read = true}) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    await api.markCommentReplyAsRead(replyId: replyId, read: read);
  }

  @override
  Future<List<ThunderComment>> mentions({bool unread = false, int limit = 50, CommentSortType sort = CommentSortType.new_, int page = 1}) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    return api.getCommentMentions(page: page, limit: limit, sort: sort, unread: unread);
  }

  @override
  Future<void> markMentionAsRead({required int mentionId, bool read = true}) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    await api.markCommentMentionAsRead(mentionId: mentionId, read: read);
  }

  @override
  Future<UnreadNotificationsCount> unreadNotificationsCount() async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    final response = await api.unreadCount();
    return UnreadNotificationsCount(replies: response.replies, mentions: response.mentions, privateMessages: response.privateMessages);
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    await api.markAllNotificationsAsRead();
  }
}
