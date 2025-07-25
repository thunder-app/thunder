import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/community/models/thunder_community.dart';
import 'package:thunder/core/data_providers/piefed_api.dart';
import 'package:thunder/core/enums/subscription_status.dart';
import 'package:thunder/core/enums/enums.dart';
import 'package:thunder/core/enums/post_sort_type.dart';
import 'package:thunder/core/enums/threadiverse_platform.dart';
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
  Future<List<ThunderPost>> getPosts({
    int page = 1,
    int? limit,
    FeedListType? feedListType,
    PostSortType? postSortType,
    int? communityId,
    String? communityName,
    bool showHidden = false,
    bool showSaved = false,
    int? personId,
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

/// Implementation of [PostRepository]
class PostRepositoryImpl implements PostRepository {
  /// The account to use for methods invoked in this repository
  Account account;

  /// The Lemmy client to use for the repository
  late LemmyApiV3 lemmy;

  /// The Piefed API to use for the repository
  late PiefedApi piefed;

  PostRepositoryImpl({required this.account}) {
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
  Future<Map<String, dynamic>?> getPost(int postId, {int? commentId}) async {
    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await lemmy.run(GetPost(id: postId, auth: account.jwt, commentId: commentId));

        final posts = await parsePosts([ThunderPost.fromLemmyPostView(response.postView.toJson())]);
        final crossPosts = response.crossPosts.map((pv) => ThunderPost.fromLemmyPostView(pv.toJson())).toList();
        final moderators = response.moderators.map((cmv) => ThunderUser.fromLemmyUser(cmv.moderator.toJson())).toList();

        return {
          'post': posts.first,
          'moderators': moderators,
          'crossPosts': crossPosts,
        };
      case ThreadiversePlatform.piefed:
        return await piefed.getPost(postId, commentId: commentId);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<List<ThunderPost>> getPosts({
    int page = 1,
    int? limit,
    int? personId,
    FeedListType? feedListType,
    PostSortType? postSortType,
    int? communityId,
    String? communityName,
    bool? showHidden,
    bool? showSaved,
    bool? likedOnly,
  }) async {
    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await lemmy.run(GetPosts(
          auth: account.jwt,
          page: page,
          limit: limit,
          sort: postSortType?.toLemmyType(),
          type: feedListType?.toLemmyType(),
          communityId: communityId,
          communityName: communityName,
          showHidden: showHidden,
          savedOnly: showSaved,
        ));
        return response.posts.map((post) => ThunderPost.fromLemmyPostView(post.toJson())).toList();
      case ThreadiversePlatform.piefed:
        return await piefed.getPosts(
          page: page,
          limit: limit,
          feedListType: feedListType,
          postSortType: postSortType,
          communityId: communityId,
          communityName: communityName,
          showSaved: showSaved,
          likedOnly: likedOnly,
        );
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
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

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        PostResponse postResponse;

        if (postIdBeingEdited != null) {
          postResponse = await lemmy.run(EditPost(
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
          postResponse = await lemmy.run(CreatePost(
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

        final posts = await parsePosts([ThunderPost.fromLemmyPostView(postResponse.postView.toJson())]);
        return posts.firstOrNull!;
      case ThreadiversePlatform.piefed:
        ThunderPost? response;

        if (postIdBeingEdited != null) {
          response = await piefed.editPost(
            postId: postIdBeingEdited,
            title: name,
            contents: body,
            nsfw: nsfw,
            languageId: languageId,
          );
        } else {
          response = await piefed.createPost(
            title: name,
            communityId: communityId,
            url: url,
            contents: body,
            nsfw: nsfw,
            languageId: languageId,
          );
        }

        final posts = await parsePosts([response]);
        return posts.firstOrNull!;
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<ThunderPost> vote(ThunderPost post, int score) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await lemmy.run(CreatePostLike(auth: account.jwt!, postId: post.id, score: score));
        return ThunderPost.fromLemmyPostView(response.postView.toJson(), media: post.media);
      case ThreadiversePlatform.piefed:
        final response = await piefed.votePost(postId: post.id, score: score);
        return response.copyWith(media: post.media);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<ThunderPost> save(ThunderPost post, bool save) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await lemmy.run(SavePost(auth: account.jwt!, postId: post.id, save: save));
        return ThunderPost.fromLemmyPostView(response.postView.toJson(), media: post.media);
      case ThreadiversePlatform.piefed:
        final response = await piefed.savePost(postId: post.id, save: save);
        return response.copyWith(media: post.media);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<bool> read(int postId, bool read) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await lemmy.run(MarkPostAsRead(auth: account.jwt!, postIds: [postId], read: read));
        return response.isSuccess();
      case ThreadiversePlatform.piefed:
        return await piefed.readPost(postIds: [postId], read: read);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<List<int>> readMultiple(List<int> postIds, bool read) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    List<int> failed = [];

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await lemmy.run(MarkPostAsRead(auth: account.jwt!, postIds: postIds, read: read));
        if (!response.isSuccess()) failed = List<int>.generate(postIds.length, (index) => index);
        break;
      case ThreadiversePlatform.piefed:
        final success = await piefed.readPost(postIds: postIds, read: read);
        if (!success) failed = List<int>.generate(postIds.length, (index) => index);
        break;
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }

    return failed;
  }

  @override
  Future<bool> hide(int postId, bool hide) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await lemmy.run(HidePost(auth: account.jwt!, postIds: [postId], hide: hide));
        return response.success;
      case ThreadiversePlatform.piefed:
        throw Exception('Hiding posts is not supported on Piefed');
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<bool> delete(int postId, bool delete) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await lemmy.run(DeletePost(auth: account.jwt!, postId: postId, deleted: delete));
        return response.postView.post.deleted == delete;
      case ThreadiversePlatform.piefed:
        return await piefed.deletePost(postId: postId, deleted: delete);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<bool> lock(int postId, bool lock) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await lemmy.run(LockPost(auth: account.jwt!, postId: postId, locked: lock));
        return response.postView.post.locked == lock;
      case ThreadiversePlatform.piefed:
        return await piefed.lockPost(postId: postId, locked: lock);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<bool> pinCommunity(int postId, bool pin) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await lemmy.run(FeaturePost(auth: account.jwt!, postId: postId, featured: pin, featureType: PostFeatureType.community));
        return response.postView.post.featuredCommunity == pin;
      case ThreadiversePlatform.piefed:
        return await piefed.pinPost(postId: postId, pinned: pin);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<bool> remove(int postId, bool remove, String reason) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await lemmy.run(RemovePost(auth: account.jwt!, postId: postId, removed: remove, reason: reason));
        return response.postView.post.removed == remove;
      case ThreadiversePlatform.piefed:
        return await piefed.removePost(postId: postId, removed: remove, reason: reason);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<PostReportResponse> report(int postId, String reason) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await lemmy.run(CreatePostReport(auth: account.jwt!, postId: postId, reason: reason));
        return response;
      case ThreadiversePlatform.piefed:
        // TODO: Implement action on Piefed
        throw Exception('This feature is not yet available');
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<ListPostReportsResponse> getPostReports({int? postId, int page = 1, int limit = 20, bool unresolved = false, int? communityId}) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await lemmy.run(ListPostReports(
          auth: account.jwt!,
          postId: postId,
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
  Future<PostReportResponse> resolvePostReport(int reportId, bool resolved) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await lemmy.run(ResolvePostReport(auth: account.jwt!, reportId: reportId, resolved: resolved));
      case ThreadiversePlatform.piefed:
        // TODO: Implement action on Piefed
        throw Exception('This feature is not yet available');
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
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
