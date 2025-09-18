import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:thunder/src/core/cache/platform_version_cache.dart';
import 'package:thunder/src/core/models/thunder_comment_report.dart';
import 'package:thunder/src/core/network/lemmy_api.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/core/network/piefed_api.dart';
import 'package:thunder/src/core/enums/comment_sort_type.dart';
import 'package:thunder/src/core/enums/threadiverse_platform.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/app/utils/global_context.dart';

/// Implementation of [CommentRepository]
class CommentRepositoryImpl implements CommentRepository {
  /// The account to use for methods invoked in this repository
  Account account;

  /// The Lemmy client to use for the repository
  late LemmyApi lemmy;

  /// The Piefed client to use for the repository
  late PiefedApi piefed;

  CommentRepositoryImpl({required this.account}) {
    final version = PlatformVersionCache().get(account.instance);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        lemmy = LemmyApi(account: account, debug: kDebugMode, version: version);
        break;
      case ThreadiversePlatform.piefed:
        piefed = PiefedApi(account: account, debug: kDebugMode, version: version);
        break;
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<ThunderComment> getComment(int commentId) async {
    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await lemmy.getComment(commentId);
      case ThreadiversePlatform.piefed:
        return await piefed.getComment(commentId);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<Map<String, dynamic>> getComments({
    required int postId,
    int? parentId,
    int? page,
    String? cursor,
    CommentSortType? commentSortType,
    int? maxDepth,
    int? limit,
    int? communityId,
  }) async {
    /// Lemmy uses page while Piefed uses cursor for pagination
    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await lemmy.getComments(
          postId: postId,
          page: page,
          limit: limit,
          maxDepth: maxDepth,
          communityId: communityId,
          parentId: parentId,
          commentSortType: commentSortType,
        );
      case ThreadiversePlatform.piefed:
        return await piefed.getComments(
          postId: postId,
          cursor: cursor,
          limit: limit,
          maxDepth: maxDepth,
          communityId: communityId,
          parentId: parentId,
          commentSortType: commentSortType,
        );
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
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

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await lemmy.createComment(
          postId: postId,
          content: content,
          parentId: parentId,
          languageId: languageId,
        );
      case ThreadiversePlatform.piefed:
        return await piefed.createComment(
          postId: postId,
          content: content,
          parentId: parentId,
          languageId: languageId,
        );
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<ThunderComment> edit({
    required int commentId,
    required String content,
    int? languageId,
  }) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await lemmy.editComment(
          commentId: commentId,
          content: content,
          languageId: languageId,
        );
      case ThreadiversePlatform.piefed:
        return await piefed.editComment(
          commentId: commentId,
          content: content,
          languageId: languageId,
        );
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<ThunderComment> vote(ThunderComment comment, int score) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await lemmy.voteComment(commentId: comment.id, score: score);
      case ThreadiversePlatform.piefed:
        return await piefed.voteComment(commentId: comment.id, score: score);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<ThunderComment> save(ThunderComment comment, bool save) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await lemmy.saveComment(commentId: comment.id, save: save);
      case ThreadiversePlatform.piefed:
        return await piefed.saveComment(commentId: comment.id, save: save);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<ThunderComment> delete(ThunderComment comment, bool deleted) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await lemmy.deleteComment(commentId: comment.id, deleted: deleted);
      case ThreadiversePlatform.piefed:
        return await piefed.deleteComment(commentId: comment.id, deleted: deleted);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<void> report(int commentId, String reason) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await lemmy.reportComment(commentId: commentId, reason: reason);
      case ThreadiversePlatform.piefed:
        return await piefed.reportComment(commentId: commentId, reason: reason);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<List<ThunderCommentReport>> getCommentReports({int? commentId, int page = 1, int limit = 20, bool unresolved = false, int? communityId}) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await lemmy.getCommentReports(commentId: commentId, page: page, limit: limit, unresolved: unresolved, communityId: communityId);
      case ThreadiversePlatform.piefed:
        throw Exception('This feature is not yet available');
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<ThunderCommentReport> resolveCommentReport(int reportId, bool resolved) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await lemmy.resolveCommentReport(reportId: reportId, resolved: resolved);
      case ThreadiversePlatform.piefed:
        throw Exception('This feature is not yet available');
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
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
