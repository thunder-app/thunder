import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/foundation/networking/networking.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';

/// Implementation of [CommentRepository]
class CommentRepositoryImpl implements CommentRepository {
  /// The account to use for methods invoked in this repository
  final Account account;

  /// The API client to use for the repository
  final ThunderApiClient _api;

  /// Creates a new CommentRepositoryImpl.
  ///
  /// An optional [api] client can be provided for testing.
  CommentRepositoryImpl({required this.account, ThunderApiClient? api}) : _api = api ?? ApiClientFactory.create(account, debug: kDebugMode);

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
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

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
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    return await _api.editComment(
      commentId: commentId,
      content: content,
      languageId: languageId,
    );
  }

  @override
  Future<ThunderComment> vote(ThunderComment comment, int score) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    return await _api.voteComment(commentId: comment.id, score: score);
  }

  @override
  Future<ThunderComment> save(ThunderComment comment, bool save) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    return await _api.saveComment(commentId: comment.id, save: save);
  }

  @override
  Future<ThunderComment> delete(ThunderComment comment, bool deleted) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    return await _api.deleteComment(commentId: comment.id, deleted: deleted);
  }

  @override
  Future<void> report(int commentId, String reason) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

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
