import 'package:thunder/src/core/core.dart';
import 'package:thunder/src/core/networking/resolved_api_client.dart';
import 'package:thunder/src/features/comment/domain/models/comment_page.dart';

/// Repository contract for comment reads and mutations.
abstract class CommentRepository {
  /// Fetches a comment by its ID
  Future<ThunderComment> getComment(int commentId);

  /// Fetches comments for a post
  Future<CommentPage> getComments({required int postId, int? parentId, int? page, String? cursor, CommentSortType? commentSortType, int? maxDepth, int? limit, int? communityId});

  /// Creates a new comment
  Future<ThunderComment> create({required int postId, required String content, int? parentId, int? languageId});

  /// Edits an existing comment
  Future<ThunderComment> edit({required int commentId, required String content, int? languageId});

  /// Votes on a comment
  Future<ThunderComment> vote(ThunderComment comment, int score);

  /// Saves or unsaves a comment
  Future<ThunderComment> save(ThunderComment comment, bool save);

  /// Deletes a comment
  Future<ThunderComment> delete(ThunderComment comment, bool deleted);

  /// Reports a comment
  Future<void> report(int commentId, String reason);
}

/// Implementation of [CommentRepository] using the unified API client
class CommentRepositoryImpl implements CommentRepository {
  /// The account to use for methods invoked in this repository
  final Account account;

  /// The API client to use for the repository
  final ResolvedApiClient _api;

  /// The localization service to use for user-facing errors
  final LocalizationService _localization;

  /// Creates a new CommentRepositoryImpl.
  ///
  /// An optional [api] client and [localization] can be provided for testing.
  CommentRepositoryImpl({required this.account, ThunderApiClient? api, LocalizationService localization = const ThunderLocalizationService()})
    : _api = ResolvedApiClient(account: account, api: api),
      _localization = localization;

  @override
  Future<ThunderComment> getComment(int commentId) async {
    final api = await _api.get();
    return api.getComment(commentId);
  }

  @override
  Future<CommentPage> getComments({required int postId, int? parentId, int? page, String? cursor, CommentSortType? commentSortType, int? maxDepth, int? limit, int? communityId}) async {
    final api = await _api.get();
    final response = await api.getComments(
      postId: postId,
      page: page,
      cursor: cursor,
      limit: limit,
      maxDepth: maxDepth,
      communityId: communityId,
      parentId: parentId,
      commentSortType: commentSortType,
    );

    return CommentPage(comments: response.comments, nextPage: response.nextPage);
  }

  @override
  Future<ThunderComment> create({required int postId, required String content, int? parentId, int? languageId}) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    return api.createComment(postId: postId, content: content, parentId: parentId, languageId: languageId);
  }

  @override
  Future<ThunderComment> edit({required int commentId, required String content, int? languageId}) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    return api.editComment(commentId: commentId, content: content, languageId: languageId);
  }

  @override
  Future<ThunderComment> vote(ThunderComment comment, int score) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    return api.voteComment(commentId: comment.id, score: score);
  }

  @override
  Future<ThunderComment> save(ThunderComment comment, bool save) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    return api.saveComment(commentId: comment.id, save: save);
  }

  @override
  Future<ThunderComment> delete(ThunderComment comment, bool deleted) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    return api.deleteComment(commentId: comment.id, deleted: deleted);
  }

  @override
  Future<void> report(int commentId, String reason) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    await api.reportComment(commentId: commentId, reason: reason);
  }
}
