import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:lemmy_api_client/v3.dart' hide CommentSortType;

import 'package:thunder/account/account.dart';
import 'package:thunder/comment/models/thunder_comment.dart';
import 'package:thunder/core/enums/comment_sort_type.dart';
import 'package:thunder/core/enums/subscription_status.dart';
import 'package:thunder/utils/global_context.dart';

/// Interface for a comment repository
abstract class CommentRepository {
  /// Fetches a comment by its ID
  Future<ThunderComment> getComment(int commentId);

  /// Fetches comments for a post
  Future<List<ThunderComment>> getComments({
    required int postId,
    int? parentId,
    int? page,
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
  Future<CommentReportResponse> report(int commentId, String reason);

  /// Get comment reports
  Future<ListCommentReportsResponse> getCommentReports({int? commentId, int page = 1, int limit = 20, bool unresolved = false, int? communityId});

  /// Resolve a comment report
  Future<CommentReportResponse> resolveCommentReport(int reportId, bool resolved);

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
    bool? isPersonAdmin,
    bool? isBotAccount,
    bool? saved,
  });
}

/// Implementation of [CommentRepository] using Lemmy API
class LemmyCommentRepository implements CommentRepository {
  /// The account to use for methods invoked in this repository
  Account account;

  /// The Lemmy client to use for the repository
  late LemmyApiV3 client;

  LemmyCommentRepository({required this.account}) {
    client = LemmyApiV3(account.instance, debug: kDebugMode);
  }

  @override
  Future<ThunderComment> getComment(int commentId) async {
    final response = await client.run(GetComment(id: commentId, auth: account.jwt));

    return ThunderComment.fromLemmyCommentView(response.commentView.toJson());
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
    final response = await client.run(GetComments(
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

    final response = await client.run(CreateComment(
      postId: postId,
      content: content,
      parentId: parentId,
      languageId: languageId,
      auth: account.jwt!,
    ));

    return ThunderComment.fromLemmyCommentView(response.commentView.toJson());
  }

  @override
  Future<ThunderComment> edit({
    required int commentId,
    required String content,
    int? languageId,
  }) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final response = await client.run(EditComment(
      commentId: commentId,
      content: content,
      languageId: languageId,
      auth: account.jwt!,
    ));

    return ThunderComment.fromLemmyCommentView(response.commentView.toJson());
  }

  @override
  Future<ThunderComment> vote(ThunderComment comment, int score) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final response = await client.run(CreateCommentLike(
      auth: account.jwt!,
      commentId: comment.id,
      score: score,
    ));

    return ThunderComment.fromLemmyCommentView(response.commentView.toJson());
  }

  @override
  Future<ThunderComment> save(ThunderComment comment, bool save) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final response = await client.run(SaveComment(
      auth: account.jwt!,
      commentId: comment.id,
      save: save,
    ));

    return ThunderComment.fromLemmyCommentView(response.commentView.toJson());
  }

  @override
  Future<ThunderComment> delete(ThunderComment comment, bool deleted) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final response = await client.run(DeleteComment(
      auth: account.jwt!,
      commentId: comment.id,
      deleted: deleted,
    ));

    return ThunderComment.fromLemmyCommentView(response.commentView.toJson());
  }

  @override
  Future<CommentReportResponse> report(int commentId, String reason) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final response = await client.run(CreateCommentReport(commentId: commentId, reason: reason, auth: account.jwt!));

    return response;
  }

  @override
  Future<ListCommentReportsResponse> getCommentReports({int? commentId, int page = 1, int limit = 20, bool unresolved = false, int? communityId}) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    return await client.run(ListCommentReports(
      auth: account.jwt!,
      commentId: commentId,
      page: page,
      limit: limit,
      unresolvedOnly: unresolved,
      communityId: communityId,
    ));
  }

  @override
  Future<CommentReportResponse> resolveCommentReport(int reportId, bool resolved) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    return await client.run(ResolveCommentReport(
      auth: account.jwt!,
      reportId: reportId,
      resolved: resolved,
    ));
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
    bool? isPersonAdmin,
    bool? isBotAccount,
    bool? saved,
  }) async {
    CommentView commentView = CommentView(
      comment: Comment(
        id: id ?? 1,
        creatorId: commentCreatorId ?? 1,
        postId: 1,
        content: commentContent ?? 'This is an example comment',
        removed: false,
        published: commentPublished ?? DateTime.now(),
        deleted: false,
        apId: '',
        local: false,
        path: path ?? '0.1',
        distinguished: false,
        languageId: 1,
      ),
      creator: Person(
        id: 1,
        name: personName ?? 'Example Username',
        banned: false,
        published: DateTime.now(),
        actorId: 'https://lemmy.world/u/testuser',
        local: false,
        deleted: false,
        botAccount: isBotAccount ?? false,
        instanceId: 1,
        admin: isPersonAdmin ?? false,
      ),
      post: Post(
        id: 1,
        name: 'Example Title',
        creatorId: 1,
        communityId: 1,
        removed: false,
        locked: false,
        published: DateTime.now(),
        deleted: false,
        nsfw: false,
        apId: '',
        local: false,
        languageId: 1,
        featuredCommunity: false,
        featuredLocal: false,
      ),
      community: Community(
        id: 1,
        name: 'Example Community',
        removed: false,
        published: DateTime.now(),
        deleted: false,
        nsfw: false,
        local: false,
        title: '',
        actorId: '',
        hidden: false,
        postingRestrictedToMods: false,
        instanceId: 1,
      ),
      counts: CommentAggregates(
        id: 1,
        commentId: 1,
        score: commentScore ?? 1,
        upvotes: commentUpvotes ?? 1,
        downvotes: commentDownvotes ?? 1,
        published: DateTime.now(),
        childCount: commentChildCount ?? 0,
      ),
      creatorBannedFromCommunity: false,
      subscribed: SubscriptionStatus.notSubscribed.toLemmyType(),
      saved: saved ?? false,
      creatorBlocked: false,
    );

    return ThunderComment.fromLemmyCommentView(commentView.toJson());
  }
}
