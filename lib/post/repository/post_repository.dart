import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/core/enums/subscription_status.dart';
import 'package:thunder/core/enums/enums.dart';
import 'package:thunder/core/enums/post_sort_type.dart';
import 'package:thunder/post/models/thunder_post.dart';
import 'package:thunder/post/utils/post.dart';
import 'package:thunder/user/models/thunder_user.dart';
import 'package:thunder/utils/global_context.dart';

extension on MarkPostAsReadResponse {
  bool isSuccess() {
    return postView != null || success == true;
  }
}

/// Interface for a post repository
abstract class PostRepository {
  /// Fetches a post by its ID. Returns the post along with moderators and cross-posts information
  Future<Map<String, dynamic>?> getPost(int postId, {int? commentId});

  /// Fetches posts from the API
  Future<GetPostsResponse> getPosts({
    int page = 1,
    FeedListType? feedListType,
    PostSortType? postSortType,
    int? communityId,
    String? communityName,
    bool showHidden = false,
    bool showSaved = false,
  });

  /// Creates a new post
  Future<ThunderPost> create({
    required int communityId,
    required String name,
    String? body,
    String? url,
    String? customThumbnail,
    String? altText,
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
  Future<PostReportResponse> report(int postId, String reason);

  /// Get post reports
  Future<ListPostReportsResponse> getPostReports({
    int? postId,
    int page = 1,
    int limit = 20,
    bool unresolved = false,
    int? communityId,
  });

  /// Resolve a post report
  Future<PostReportResponse> resolvePostReport(int reportId, bool resolved);
}

/// Implementation of [PostRepository] using Lemmy API
class LemmyPostRepository implements PostRepository {
  /// The account to use for methods invoked in this repository
  Account account;

  /// The Lemmy client to use for the repository
  late LemmyApiV3 client;

  LemmyPostRepository({required this.account}) {
    client = LemmyApiV3(account.instance, debug: kDebugMode);
  }

  @override
  Future<Map<String, dynamic>?> getPost(int postId, {int? commentId}) async {
    final response = await client.run(GetPost(id: postId, auth: account.jwt, commentId: commentId));

    // Parse the posts and add in media information which is used elsewhere in the app
    List<ThunderPost> posts = await parsePosts([response.postView]);
    ThunderPost post = posts.first;

    // Convert cross-posts to ThunderPost objects
    List<ThunderPost> crossPosts = response.crossPosts.map((pv) => ThunderPost.fromLemmyPostView(pv.toJson())).toList();
    List<ThunderUser> moderators = response.moderators.map((cmv) => ThunderUser.fromLemmyUser(cmv.moderator.toJson())).toList();

    return {
      'post': post,
      'moderators': moderators,
      'crossPosts': crossPosts,
    };
  }

  @override
  Future<GetPostsResponse> getPosts({
    int page = 1,
    FeedListType? feedListType,
    PostSortType? postSortType,
    int? communityId,
    String? communityName,
    bool showHidden = false,
    bool showSaved = false,
  }) async {
    return await client.run(GetPosts(
      auth: account.jwt,
      page: page,
      sort: postSortType?.toLemmyType(),
      type: feedListType?.toLemmyType(),
      communityId: communityId,
      communityName: communityName,
      showHidden: showHidden,
      savedOnly: showSaved,
    ));
  }

  @override
  Future<ThunderPost> create({
    required int communityId,
    required String name,
    String? body,
    String? url,
    String? customThumbnail,
    String? altText,
    bool? nsfw,
    int? postIdBeingEdited,
    int? languageId,
  }) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    PostResponse postResponse;
    if (postIdBeingEdited != null) {
      postResponse = await client.run(EditPost(
        auth: account.jwt!,
        name: name,
        body: body,
        url: url?.isEmpty == true ? null : url,
        customThumbnail: customThumbnail?.isEmpty == true ? null : customThumbnail,
        altText: altText?.isEmpty == true ? null : altText,
        nsfw: nsfw,
        postId: postIdBeingEdited,
        languageId: languageId,
      ));
    } else {
      postResponse = await client.run(CreatePost(
        auth: account.jwt!,
        communityId: communityId,
        name: name,
        body: body,
        url: url?.isEmpty == true ? null : url,
        customThumbnail: customThumbnail?.isEmpty == true ? null : customThumbnail,
        altText: altText?.isEmpty == true ? null : altText,
        nsfw: nsfw,
        languageId: languageId,
      ));
    }

    final posts = await parsePosts([postResponse.postView]);
    return posts.firstOrNull!;
  }

  @override
  Future<ThunderPost> vote(ThunderPost post, int score) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final response = await client.run(CreatePostLike(auth: account.jwt!, postId: post.id, score: score));
    return ThunderPost.fromLemmyPostView(response.postView.toJson(), media: post.media);
  }

  @override
  Future<ThunderPost> save(ThunderPost post, bool save) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final response = await client.run(SavePost(auth: account.jwt!, postId: post.id, save: save));
    return ThunderPost.fromLemmyPostView(response.postView.toJson(), media: post.media);
  }

  @override
  Future<bool> read(int postId, bool read) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final response = await client.run(MarkPostAsRead(auth: account.jwt!, postIds: [postId], read: read));
    return response.isSuccess();
  }

  @override
  Future<List<int>> readMultiple(List<int> postIds, bool read) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    List<int> failed = [];

    final response = await client.run(MarkPostAsRead(auth: account.jwt!, postIds: postIds, read: read));
    if (!response.isSuccess()) failed = List<int>.generate(postIds.length, (index) => index);

    return failed;
  }

  @override
  Future<bool> hide(int postId, bool hide) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final response = await client.run(HidePost(auth: account.jwt!, postIds: [postId], hide: hide));
    return response.success;
  }

  @override
  Future<bool> delete(int postId, bool delete) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final response = await client.run(DeletePost(auth: account.jwt!, postId: postId, deleted: delete));
    return response.postView.post.deleted == delete;
  }

  @override
  Future<bool> lock(int postId, bool lock) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final response = await client.run(LockPost(auth: account.jwt!, postId: postId, locked: lock));
    return response.postView.post.locked == lock;
  }

  @override
  Future<bool> pinCommunity(int postId, bool pin) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final response = await client.run(FeaturePost(auth: account.jwt!, postId: postId, featured: pin, featureType: PostFeatureType.community));
    return response.postView.post.featuredCommunity == pin;
  }

  @override
  Future<bool> remove(int postId, bool remove, String reason) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final response = await client.run(RemovePost(auth: account.jwt!, postId: postId, removed: remove, reason: reason));
    return response.postView.post.removed == remove;
  }

  @override
  Future<PostReportResponse> report(int postId, String reason) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final response = await client.run(CreatePostReport(auth: account.jwt!, postId: postId, reason: reason));
    return response;
  }

  @override
  Future<ListPostReportsResponse> getPostReports({int? postId, int page = 1, int limit = 20, bool unresolved = false, int? communityId}) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    return await client.run(ListPostReports(
      auth: account.jwt!,
      postId: postId,
      page: page,
      limit: limit,
      unresolvedOnly: unresolved,
      communityId: communityId,
    ));
  }

  @override
  Future<PostReportResponse> resolvePostReport(int reportId, bool resolved) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    return await client.run(ResolvePostReport(
      auth: account.jwt!,
      reportId: reportId,
      resolved: resolved,
    ));
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
    PostView postView = PostView(
      post: Post(
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
      ),
      creator: Person(
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
      community: Community(
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
      ),
      creatorBannedFromCommunity: false,
      counts: PostAggregates(
        id: 1,
        postId: 1,
        comments: commentCount ?? 0,
        score: scoreCount ?? 0,
        upvotes: 0,
        downvotes: 0,
        published: DateTime.now(),
      ),
      subscribed: SubscriptionStatus.notSubscribed.toLemmyType(),
      saved: saved ?? false,
      read: read ?? false,
      creatorBlocked: false,
      unreadComments: 0,
    );

    List<ThunderPost> posts = await parsePosts([postView]);

    return Future.value(posts.firstOrNull);
  }
}
