import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/foundation/errors/errors.dart';
import 'package:thunder/src/foundation/networking/networking.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/post/post.dart';

/// Interface for a post repository
abstract class PostRepository {
  /// Fetches a post by its ID. Returns the post along with moderators and cross-posts information
  Future<Map<String, dynamic>?> getPost(int postId, {int? commentId});

  /// Fetches posts from the API
  Future<Map<String, dynamic>> getPosts({
    String? cursor,
    int? limit,
    FeedListType? feedListType,
    PostSortType? postSortType,
    int? communityId,
    String? communityName,
    bool showHidden = false,
    bool showSaved = false,
    int? personId,
    String? query,
    bool? likedOnly,
    int? feedId,
    int? topicId,
    bool? ignoreSticky,
  });

  /// Creates a new post
  Future<ThunderPost> create({
    required int communityId,
    required String name,
    String? body,
    String? url,
    String? customThumbnail,
    String? altText,
    List<String>? tags,
    List<int>? flairIds,
    bool? nsfw,
    int? postIdBeingEdited,
    int? languageId,
  });

  /// Creates a placeholder post from the given parameters. This is mainly used to display a preview of the post
  /// with the applied settings on Settings -> Appearance -> Posts page.
  Future<ThunderPost?> createExample({
    String? postTitle,
    String? postUrl,
    String? postBody,
    String? postThumbnailUrl,
    String? postAltText,
    bool? locked,
    bool? nsfw,
    bool? pinned,
    String? personName,
    String? personDisplayName,
    String? personInstance,
    String? communityName,
    String? instanceUrl,
    int? commentCount,
    int? scoreCount,
    bool? saved,
    bool? read,
  });

  /// Votes on a post
  Future<ThunderPost> vote(ThunderPost post, int score);

  /// Saves or unsaves a post
  Future<ThunderPost> save(ThunderPost post, bool save);

  /// Marks a post as read/unread
  Future<bool> read(int postId, bool read);

  /// Marks multiple posts as read/unread
  Future<List<int>> readMultiple(List<int> postIds, bool read);

  /// Marks a post as hidden/unhidden
  Future<bool> hide(int postId, bool hide);

  /// Deletes a post
  Future<bool> delete(int postId, bool delete);

  /// Locks/unlocks a post
  Future<bool> lock(int postId, bool lock);

  /// Pins/unpins a post to a community
  Future<bool> pinCommunity(int postId, bool pin);

  /// Removes/restores a post (moderator action)
  Future<bool> remove(int postId, bool remove, String reason);

  /// Reports a post
  /// @TODO: Change the return type to an internal model
  Future<void> report(int postId, String reason);

  /// Get post reports
  Future<List<ThunderPostReport>> getPostReports({
    int? postId,
    int page = 1,
    int limit = 20,
    bool unresolved = false,
    int? communityId,
  });

  /// Resolve a post report
  Future<ThunderPostReport> resolvePostReport(int reportId, bool resolved);
}

/// Implementation of [PostRepository]
class PostRepositoryImpl implements PostRepository {
  /// The account to use for methods invoked in this repository
  final Account account;

  /// The API client to use for the repository
  final ThunderApiClient _api;

  /// Creates a new PostRepositoryImpl.
  ///
  /// An optional [api] client can be provided for testing.
  PostRepositoryImpl({required this.account, ThunderApiClient? api}) : _api = api ?? ApiClientFactory.create(account, debug: kDebugMode);

  @override
  Future<Map<String, dynamic>?> getPost(int postId, {int? commentId}) async {
    final response = await _api.getPost(postId, commentId: commentId);

    final parsedPost = await parsePostWithCurrentPreferences(response.post);
    final parsedCrossPosts = await Future.wait(response.crossPosts.map(parsePostWithCurrentPreferences));

    return {
      'post': parsedPost,
      'moderators': response.moderators,
      'cross_posts': parsedCrossPosts,
      // Keep camelCase key for existing consumers.
      'crossPosts': parsedCrossPosts,
    };
  }

  @override
  Future<Map<String, dynamic>> getPosts({
    String? cursor,
    int? limit,
    int? personId,
    FeedListType? feedListType,
    PostSortType? postSortType,
    int? communityId,
    String? communityName,
    bool? showHidden,
    bool? showSaved,
    bool? likedOnly,
    String? query,
    int? feedId,
    int? topicId,
    bool? ignoreSticky,
  }) async {
    final response = await _api.getPosts(
      cursor: cursor,
      limit: limit,
      feedListType: feedListType,
      postSortType: postSortType,
      communityId: communityId,
      communityName: communityName,
      query: query,
      personId: personId,
      likedOnly: likedOnly,
      feedId: feedId,
      topicId: topicId,
      ignoreSticky: ignoreSticky,
      showHidden: showHidden,
      showSaved: showSaved,
    );

    return {
      'posts': response.posts,
      'next_page': response.nextPage,
    };
  }

  @override
  Future<ThunderPost> create({
    required int communityId,
    required String name,
    String? body,
    String? url,
    String? customThumbnail,
    String? altText,
    List<String>? tags,
    List<int>? flairIds,
    bool? nsfw,
    int? postIdBeingEdited,
    int? languageId,
  }) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    ThunderPost response;

    if (postIdBeingEdited != null) {
      response = await _api.editPostWithMetadata(
        postId: postIdBeingEdited,
        title: name,
        contents: body,
        url: url?.isEmpty == true ? null : url,
        customThumbnail: customThumbnail?.isEmpty == true ? null : customThumbnail,
        altText: altText?.isEmpty == true ? null : altText,
        tags: tags,
        flairIds: flairIds,
        nsfw: nsfw,
        languageId: languageId,
      );
    } else {
      response = await _api.createPostWithMetadata(
        communityId: communityId,
        title: name,
        contents: body,
        url: url?.isEmpty == true ? null : url,
        customThumbnail: customThumbnail?.isEmpty == true ? null : customThumbnail,
        altText: altText?.isEmpty == true ? null : altText,
        tags: tags,
        flairIds: flairIds,
        nsfw: nsfw,
        languageId: languageId,
      );
    }

    final posts = await parsePosts([response]);
    return posts.firstOrNull!;
  }

  @override
  Future<ThunderPost> vote(ThunderPost post, int score) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final response = await _api.votePost(postId: post.id, score: score);
    return response.copyWith(media: post.media);
  }

  @override
  Future<ThunderPost> save(ThunderPost post, bool save) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final response = await _api.savePost(postId: post.id, save: save);
    return response.copyWith(media: post.media);
  }

  @override
  Future<bool> read(int postId, bool read) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    return await _api.readPost(postIds: [postId], read: read);
  }

  @override
  Future<List<int>> readMultiple(List<int> postIds, bool read) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final success = await _api.readPost(postIds: postIds, read: read);
    return success ? [] : List<int>.generate(postIds.length, (index) => index);
  }

  @override
  Future<bool> hide(int postId, bool hide) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    if (!_api.supportsHidePosts) {
      throw UnsupportedFeatureException('Hiding posts', platformName: _api.platformName);
    }

    return await _api.hidePost(postId: postId, hide: hide);
  }

  @override
  Future<bool> delete(int postId, bool delete) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    return await _api.deletePost(postId: postId, deleted: delete);
  }

  @override
  Future<bool> lock(int postId, bool lock) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    return await _api.lockPost(postId: postId, locked: lock);
  }

  @override
  Future<bool> pinCommunity(int postId, bool pin) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    return await _api.pinPost(postId: postId, pinned: pin);
  }

  @override
  Future<bool> remove(int postId, bool remove, String reason) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    return await _api.removePost(postId: postId, removed: remove, reason: reason);
  }

  @override
  Future<void> report(int postId, String reason) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    await _api.reportPost(postId: postId, reason: reason);
  }

  @override
  Future<List<ThunderPostReport>> getPostReports({
    int? postId,
    int page = 1,
    int limit = 20,
    bool unresolved = false,
    int? communityId,
  }) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    if (!_api.supportsPostReports) {
      throw UnsupportedFeatureException('Post reports', platformName: _api.platformName);
    }

    return await _api.getPostReports(
      postId: postId,
      page: page,
      limit: limit,
      unresolved: unresolved,
      communityId: communityId,
    );
  }

  @override
  Future<ThunderPostReport> resolvePostReport(int reportId, bool resolved) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    if (!_api.supportsPostReports) {
      throw UnsupportedFeatureException('Post reports', platformName: _api.platformName);
    }

    return await _api.resolvePostReport(reportId: reportId, resolved: resolved);
  }

  @override
  Future<ThunderPost?> createExample({
    String? postTitle,
    String? postUrl,
    String? postBody,
    String? postThumbnailUrl,
    String? postAltText,
    bool? locked,
    bool? nsfw,
    bool? pinned,
    String? personName,
    String? personDisplayName,
    String? personInstance,
    String? communityName,
    String? instanceUrl,
    int? commentCount,
    int? scoreCount,
    bool? saved,
    bool? read,
  }) async {
    ThunderPost post = ThunderPost(
      id: 1,
      name: postTitle ?? 'Example Title',
      url: postUrl,
      body: postBody,
      thumbnailUrl: postThumbnailUrl,
      altText: postAltText,
      creatorId: 1,
      communityId: 1,
      removed: false,
      locked: locked ?? false,
      published: DateTime.now(),
      deleted: false,
      nsfw: nsfw ?? false,
      apId: '',
      local: false,
      languageId: 0,
      featuredCommunity: pinned ?? false,
      featuredLocal: false,
      creator: ThunderUser(
        id: 1,
        name: personName ?? 'Example Username',
        displayName: personDisplayName ?? 'Example Name',
        banned: false,
        published: DateTime.now(),
        actorId: 'https://$personInstance/u/$personName',
        local: false,
        deleted: false,
        botAccount: false,
        instanceId: 1,
      ),
      community: ThunderCommunity(
        id: 1,
        name: communityName ?? 'Example Community',
        title: '',
        removed: false,
        published: DateTime.now(),
        deleted: false,
        nsfw: false,
        actorId: instanceUrl ?? 'https://thunder.lemmy',
        local: false,
        hidden: false,
        postingRestrictedToMods: false,
        instanceId: 1,
        visibility: 'Public',
      ),
      creatorBannedFromCommunity: false,
      comments: commentCount ?? 0,
      score: scoreCount ?? 0,
      upvotes: 0,
      downvotes: 0,
      newestCommentTime: DateTime.now(),
      subscribed: SubscriptionStatus.notSubscribed,
      saved: saved ?? false,
      read: read ?? false,
      creatorBlocked: false,
      unreadComments: 0,
    );

    List<ThunderPost> posts = await parsePosts([post]);
    return Future.value(posts.firstOrNull);
  }
}
