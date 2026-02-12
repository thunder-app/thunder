import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:thunder/src/app/utils/global_context.dart';
import 'package:thunder/src/core/enums/comment_sort_type.dart';
import 'package:thunder/src/core/models/thunder_comment_report.dart';
import 'package:thunder/src/core/network/api_client_factory.dart';
import 'package:thunder/src/core/network/api_exception.dart';
import 'package:thunder/src/core/network/thunder_api_client.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/user/user.dart';

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
  Future<List<ThunderCommentReport>> getCommentReports({
    int? commentId,
    int page = 1,
    int limit = 20,
    bool unresolved = false,
    int? communityId,
  }) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    if (!_api.supportsCommentReports) {
      throw UnsupportedFeatureException('Comment reports', platformName: _api.platformName);
    }

    return await _api.getCommentReports(
      commentId: commentId,
      page: page,
      limit: limit,
      unresolved: unresolved,
      communityId: communityId,
    );
  }

  @override
  Future<ThunderCommentReport> resolveCommentReport(int reportId, bool resolved) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    if (!_api.supportsCommentReports) {
      throw UnsupportedFeatureException('Comment reports', platformName: _api.platformName);
    }

    return await _api.resolveCommentReport(reportId: reportId, resolved: resolved);
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
      removed: false,
      published: commentPublished ?? DateTime.now(),
      deleted: false,
      apId: 'https://example.com/comment/$id',
      local: false,
      path: path ?? '',
      distinguished: false,
      languageId: 0,
      score: commentScore ?? 0,
      upvotes: commentUpvotes ?? 0,
      downvotes: commentDownvotes ?? 0,
      childCount: commentChildCount ?? 0,
      creatorBannedFromCommunity: false,
      bannedFromCommunity: false,
      creatorIsModerator: false,
      creatorIsAdmin: isPersonAdmin ?? false,
      saved: saved ?? false,
      creator: ThunderUser(
        id: 1,
        name: personName ?? 'Example Username',
        banned: false,
        published: DateTime.now(),
        actorId: 'https://example.com/user/$personName',
        local: false,
        deleted: false,
        botAccount: isBotAccount ?? false,
        instanceId: 1,
        avatar: personAvatar,
      ),
    );
  }
}
