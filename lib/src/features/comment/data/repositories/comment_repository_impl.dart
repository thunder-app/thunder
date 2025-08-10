import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:lemmy_api_client/v3.dart' hide CommentSortType;

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
  late LemmyApiV3 lemmy;

  /// The Piefed client to use for the repository
  late PiefedApi piefed;

  CommentRepositoryImpl({required this.account}) {
    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        lemmy = LemmyApiV3(account.instance, debug: kDebugMode);
        break;
      case ThreadiversePlatform.piefed:
        piefed = PiefedApi(account: account, debug: kDebugMode);
        break;
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<ThunderComment> getComment(int commentId) async {
    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await lemmy.run(GetComment(id: commentId, auth: account.jwt));
        return ThunderComment.fromLemmyCommentView(response.commentView.toJson());
      case ThreadiversePlatform.piefed:
        final response = await piefed.getComment(commentId);
        return ThunderComment.fromPiefedCommentView(response['comment']);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<List<ThunderComment>> getComments({
    required int postId,
    int? parentId,
    int? page,
    CommentSortType? commentSortType,
    int? maxDepth,
    int? limit,
    int? communityId,
  }) async {
    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await lemmy.run(GetComments(
          auth: account.jwt,
          communityId: communityId,
          postId: postId,
          parentId: parentId,
          sort: commentSortType?.toLemmyType(),
          limit: limit,
          maxDepth: maxDepth,
          page: page,
          type: ListingType.all,
        ));

        return response.comments.map((cv) => ThunderComment.fromLemmyCommentView(cv.toJson())).toList();
      case ThreadiversePlatform.piefed:
        final response = await piefed.getComments(
          postId: postId,
          page: page,
          limit: limit,
          maxDepth: maxDepth,
          communityId: communityId,
          parentId: parentId,
          commentSortType: commentSortType,
        );

        return response;
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
        final response = await lemmy.run(CreateComment(
          postId: postId,
          content: content,
          parentId: parentId,
          languageId: languageId,
          auth: account.jwt!,
        ));
        return ThunderComment.fromLemmyCommentView(response.commentView.toJson());
      case ThreadiversePlatform.piefed:
        final response = await piefed.createComment(
          postId: postId,
          content: content,
          parentId: parentId,
          languageId: languageId,
        );
        return response;
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
        final response = await lemmy.run(EditComment(
          commentId: commentId,
          content: content,
          languageId: languageId,
          auth: account.jwt!,
        ));
        return ThunderComment.fromLemmyCommentView(response.commentView.toJson());
      case ThreadiversePlatform.piefed:
        final response = await piefed.editComment(
          commentId: commentId,
          content: content,
          languageId: languageId,
        );
        return response;
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
        final response = await lemmy.run(CreateCommentLike(auth: account.jwt!, commentId: comment.id, score: score));
        return ThunderComment.fromLemmyCommentView(response.commentView.toJson());
      case ThreadiversePlatform.piefed:
        final response = await piefed.voteComment(commentId: comment.id, score: score);
        return response;
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
        final response = await lemmy.run(SaveComment(auth: account.jwt!, commentId: comment.id, save: save));
        return ThunderComment.fromLemmyCommentView(response.commentView.toJson());
      case ThreadiversePlatform.piefed:
        final response = await piefed.saveComment(commentId: comment.id, save: save);
        return response;
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
        final response = await lemmy.run(DeleteComment(auth: account.jwt!, commentId: comment.id, deleted: deleted));
        return ThunderComment.fromLemmyCommentView(response.commentView.toJson());
      case ThreadiversePlatform.piefed:
        final response = await piefed.deleteComment(commentId: comment.id, deleted: deleted);
        return response;
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<CommentReportResponse> report(int commentId, String reason) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await lemmy.run(CreateCommentReport(commentId: commentId, reason: reason, auth: account.jwt!));
        return response;
      case ThreadiversePlatform.piefed:
        // TODO: Implement action on Piefed
        throw Exception('This feature is not yet available');
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<ListCommentReportsResponse> getCommentReports({int? commentId, int page = 1, int limit = 20, bool unresolved = false, int? communityId}) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await lemmy.run(ListCommentReports(
          auth: account.jwt!,
          commentId: commentId,
          page: page,
          limit: limit,
          unresolvedOnly: unresolved,
          communityId: communityId,
        ));
      case ThreadiversePlatform.piefed:
        // TODO: Implement action on Piefed
        throw Exception('This feature is not yet available');
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<CommentReportResponse> resolveCommentReport(int reportId, bool resolved) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await lemmy.run(ResolveCommentReport(auth: account.jwt!, reportId: reportId, resolved: resolved));
      case ThreadiversePlatform.piefed:
        // TODO: Implement action on Piefed
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
