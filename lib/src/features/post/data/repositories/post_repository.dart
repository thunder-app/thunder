import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:thunder/src/app/utils/global_context.dart';
import 'package:thunder/src/core/cache/platform_version_cache.dart';
import 'package:thunder/src/core/models/thunder_post_report.dart';
import 'package:thunder/src/core/network/lemmy_api.dart';
import 'package:thunder/src/core/network/piefed_api.dart';
import 'package:thunder/src/core/enums/subscription_status.dart';
import 'package:thunder/src/core/enums/enums.dart';
import 'package:thunder/src/core/enums/post_sort_type.dart';
import 'package:thunder/src/core/enums/threadiverse_platform.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/user/user.dart';

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
  Account account;

  /// The Lemmy client to use for the repository
  late LemmyApi lemmy;

  /// The Piefed API to use for the repository
  late PiefedApi piefed;

  PostRepositoryImpl({required this.account}) {
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
  Future<Map<String, dynamic>?> getPost(int postId, {int? commentId}) async {
    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await lemmy.getPost(postId, commentId: commentId);
      case ThreadiversePlatform.piefed:
        return await piefed.getPost(postId, commentId: commentId);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
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
  }) async {
    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        // Use page-based pagination for Lemmy for 0.19.x instances as there are some performance issues with cursor-based pagination.
        // See https://github.com/LemmyNet/lemmy/issues/6171, https://lemmy.world/post/40266465/21176898
        // TODO: Once 1.x.x is released, we can switch back to cursor-based pagination.
        final page = cursor != null ? int.tryParse(cursor) ?? 1 : 1;

        final response = await lemmy.getPosts(
          page: page,
          limit: limit,
          postSortType: postSortType,
          feedListType: feedListType,
          communityId: communityId,
          communityName: communityName,
          showHidden: showHidden,
          showSaved: showSaved,
        );

        // Return next page as string cursor for Lemmy
        final nextPage = response['posts'].isNotEmpty ? (page + 1).toString() : null;
        return {
          'posts': response['posts'],
          'next_page': nextPage,
        };
      case ThreadiversePlatform.piefed:
        // PieFed uses integer page-based pagination. The cursor in this case is the page number.
        final page = cursor != null ? int.tryParse(cursor) ?? 1 : 1;

        final posts = await piefed.getPosts(
          page: page,
          limit: limit,
          feedListType: feedListType,
          postSortType: postSortType,
          communityId: communityId,
          communityName: communityName,
          showSaved: showSaved,
          likedOnly: likedOnly,
        );

        // Return next page as string cursor for PieFed
        final nextPage = posts.isNotEmpty ? (page + 1).toString() : null;
        return {
          'posts': posts,
          'next_page': nextPage,
        };
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
        ThunderPost? response;

        if (postIdBeingEdited != null) {
          response = await lemmy.editPost(
            postId: postIdBeingEdited,
            title: name,
            contents: body,
            url: url?.isEmpty == true ? null : url,
            customThumbnail: customThumbnail?.isEmpty == true ? null : customThumbnail,
            altText: altText?.isEmpty == true ? null : altText,
            nsfw: nsfw,
            languageId: languageId,
          );
        } else {
          response = await lemmy.createPost(
            communityId: communityId,
            title: name,
            contents: body,
            url: url?.isEmpty == true ? null : url,
            customThumbnail: customThumbnail?.isEmpty == true ? null : customThumbnail,
            altText: altText?.isEmpty == true ? null : altText,
            nsfw: nsfw,
            languageId: languageId,
          );
        }

        final posts = await parsePosts([response]);
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
        final response = await lemmy.votePost(postId: post.id, score: score);
        return response.copyWith(media: post.media);
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
        final response = await lemmy.savePost(postId: post.id, save: save);
        return response.copyWith(media: post.media);
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
        return await lemmy.readPost(postIds: [postId], read: read);
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
        final response = await lemmy.readPost(postIds: postIds, read: read);
        if (!response) failed = List<int>.generate(postIds.length, (index) => index);
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
        return await lemmy.hidePost(postId: postId, hide: hide);
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
        return await lemmy.deletePost(postId: postId, deleted: delete);
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
        return await lemmy.lockPost(postId: postId, locked: lock);
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
        return await lemmy.pinPost(postId: postId, pinned: pin);
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
        return await lemmy.removePost(postId: postId, removed: remove, reason: reason);
      case ThreadiversePlatform.piefed:
        return await piefed.removePost(postId: postId, removed: remove, reason: reason);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<void> report(int postId, String reason) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await lemmy.reportPost(postId: postId, reason: reason);
      case ThreadiversePlatform.piefed:
        return await piefed.reportPost(postId: postId, reason: reason);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<List<ThunderPostReport>> getPostReports({int? postId, int page = 1, int limit = 20, bool unresolved = false, int? communityId}) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await lemmy.getPostReports(postId: postId, page: page, limit: limit, unresolved: unresolved, communityId: communityId);
      case ThreadiversePlatform.piefed:
        throw Exception('This feature is not yet available');
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<ThunderPostReport> resolvePostReport(int reportId, bool resolved) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await lemmy.resolvePostReport(reportId: reportId, resolved: resolved);
      case ThreadiversePlatform.piefed:
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
