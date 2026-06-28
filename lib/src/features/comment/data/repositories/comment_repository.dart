import 'package:flutter/foundation.dart';

import 'package:thunder/src/foundation/foundation.dart';
import 'package:thunder/src/features/comment/domain/models/comment_page.dart';

/// Repository contract for comment reads and mutations.
abstract class CommentRepository {
  /// Fetches a comment by its ID
  Future<ThunderComment> getComment(int commentId);

  /// Fetches comments for a post
  Future<CommentPage> getComments({
    required int postId,
    int? parentId,
    int? page,
    String? cursor,
    CommentSortType? commentSortType,
    int? maxDepth,
    int? limit,
    int? communityId,
  });

  /// Creates a new comment
  Future<ThunderComment> create({
    required int postId,
    required String content,
    int? parentId,
    int? languageId,
  });

  /// Edits an existing comment
  Future<ThunderComment> edit({
    required int commentId,
    required String content,
    int? languageId,
  });

  /// Votes on a comment
  Future<ThunderComment> vote(ThunderComment comment, int score);

  /// Saves or unsaves a comment
  Future<ThunderComment> save(ThunderComment comment, bool save);

  /// Deletes a comment
  Future<ThunderComment> delete(ThunderComment comment, bool deleted);

  /// Reports a comment
  Future<void> report(int commentId, String reason);

  /// Creates a placeholder comment from the given parameters. This is mainly used to display a preview of the comment
  /// with the applied settings on Settings -> Appearance -> Comments page.
  Future<ThunderComment> createExample({
    int? id,
    String? path,
    String? commentContent,
    int? commentCreatorId,
    int? commentScore,
    int? commentUpvotes,
    int? commentDownvotes,
    DateTime? commentPublished,
    int? commentChildCount,
    String? personName,
    String? personAvatar,
    bool? isPersonAdmin,
    bool? isBotAccount,
    bool? saved,
  });
}

/// Implementation of [CommentRepository] using the unified API client
class CommentRepositoryImpl implements CommentRepository {
  /// The account to use for methods invoked in this repository
  final Account account;

  /// The API client to use for the repository
  final ThunderApiClient _api;

  /// The localization service to use for user-facing errors
  final LocalizationService _localization;

  /// Creates a new CommentRepositoryImpl.
  ///
  /// An optional [api] client and [localization] can be provided for testing.
  CommentRepositoryImpl({
    required this.account,
    ThunderApiClient? api,
    LocalizationService localization = const ThunderLocalizationService(),
  })  : _api = api ?? ApiClientFactory.create(account, debug: kDebugMode),
        _localization = localization;

  @override
  Future<ThunderComment> getComment(int commentId) async {
    return await _api.getComment(commentId);
  }

  @override
  Future<CommentPage> getComments({
    required int postId,
    int? parentId,
    int? page,
    String? cursor,
    CommentSortType? commentSortType,
    int? maxDepth,
    int? limit,
    int? communityId,
  }) async {
    final response = await _api.getComments(
      postId: postId,
      page: page,
      cursor: cursor,
      limit: limit,
      maxDepth: maxDepth,
      communityId: communityId,
      parentId: parentId,
      commentSortType: commentSortType,
    );

    return CommentPage(
      comments: response.comments,
      nextPage: response.nextPage,
    );
  }

  @override
  Future<ThunderComment> create({
    required int postId,
    required String content,
    int? parentId,
    int? languageId,
  }) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    return await _api.createComment(
      postId: postId,
      content: content,
      parentId: parentId,
      languageId: languageId,
    );
  }

  @override
  Future<ThunderComment> edit({
    required int commentId,
    required String content,
    int? languageId,
  }) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    return await _api.editComment(
      commentId: commentId,
      content: content,
      languageId: languageId,
    );
  }

  @override
  Future<ThunderComment> vote(ThunderComment comment, int score) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    return await _api.voteComment(commentId: comment.id, score: score);
  }

  @override
  Future<ThunderComment> save(ThunderComment comment, bool save) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    return await _api.saveComment(commentId: comment.id, save: save);
  }

  @override
  Future<ThunderComment> delete(ThunderComment comment, bool deleted) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    return await _api.deleteComment(commentId: comment.id, deleted: deleted);
  }

  @override
  Future<void> report(int commentId, String reason) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    await _api.reportComment(commentId: commentId, reason: reason);
  }

  @override
  Future<ThunderComment> createExample({
    int? id,
    String? path,
    String? commentContent,
    int? commentCreatorId,
    int? commentScore,
    int? commentUpvotes,
    int? commentDownvotes,
    DateTime? commentPublished,
    int? commentChildCount,
    String? personName,
    String? personAvatar,
    bool? isPersonAdmin,
    bool? isBotAccount,
    bool? saved,
  }) async {
    return ThunderComment(
      id: id ?? 1,
      creatorId: commentCreatorId ?? 1,
      postId: 1,
      content: commentContent ?? 'Example Comment',
      published: commentPublished ?? DateTime.now(),
      apId: 'https://example.com/comment/$id',
      path: path ?? '',
      languageId: 0,
      status: const CommentStatus(deleted: false, removed: false, local: false, distinguished: false),
      counts: CommentCounts(score: commentScore ?? 0, upvotes: commentUpvotes ?? 0, downvotes: commentDownvotes ?? 0, childCount: commentChildCount ?? 0),
      context: CommentContext(
        creatorBannedFromCommunity: false,
        bannedFromCommunity: false,
        creatorIsModerator: false,
        creatorIsAdmin: isPersonAdmin ?? false,
        saved: saved ?? false,
      ),
      creator: ThunderUser(
        id: 1,
        name: personName ?? 'Example Username',
        published: DateTime.now(),
        actorId: 'https://example.com/user/$personName',
        instanceId: 1,
        avatar: personAvatar,
        status: UserStatus(banned: false, local: false, deleted: false, botAccount: isBotAccount ?? false),
      ),
    );
  }
}
