import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:thunder/src/core/cache/platform_version_cache.dart';
import 'package:thunder/src/core/network/lemmy_api.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/core/network/piefed_api.dart';
import 'package:thunder/src/core/enums/feed_list_type.dart';
import 'package:thunder/src/core/enums/meta_search_type.dart';
import 'package:thunder/src/core/enums/search_sort_type.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/core/enums/threadiverse_platform.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/shared/utils/links.dart';

/// Interface for a search repository
abstract class SearchRepository {
  /// Searches for posts, comments, users, communities, etc.
  /// @TODO: Change the return type to an internal model
  Future<Map<String, dynamic>> search({
    required String query,
    MetaSearchType? type,
    SearchSortType? sort,
    FeedListType? listingType,
    int? limit,
    int? page,
    int? communityId,
    int? creatorId,
  });

  /// Resolves a given query
  Future<Map<String, dynamic>> resolve({required String query});
}

/// Implementation of [SearchRepository]
class SearchRepositoryImpl implements SearchRepository {
  /// The account to use for methods invoked in this repository
  Account account;

  /// The Lemmy client to use for the repository (initialized for Lemmy platforms)
  LemmyApi? _lemmy;

  /// The Piefed client to use for the repository (initialized for Piefed platforms)
  PiefedApi? _piefed;

  SearchRepositoryImpl({required this.account}) {
    final version = PlatformVersionCache().get(account.instance);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        _lemmy = LemmyApi(account: account, debug: kDebugMode, version: version);
        break;
      case ThreadiversePlatform.piefed:
        _piefed = PiefedApi(account: account, debug: kDebugMode, version: version);
        break;
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<Map<String, dynamic>> search({
    required String query,
    MetaSearchType? type,
    SearchSortType? sort,
    FeedListType? listingType,
    int? limit,
    int? page,
    int? communityId,
    int? creatorId,
  }) async {
    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final lemmy = _lemmy!;
        final response = await lemmy.search(
          query: query,
          type: type,
          sort: sort,
          listingType: listingType,
          limit: limit,
          page: page,
          communityId: communityId,
          creatorId: creatorId,
        );

        List<ThunderCommunity> communities = response['communities'] != null ? response['communities'].map<ThunderCommunity>((cv) => ThunderCommunity.fromLemmyCommunityView(cv)).toList() : [];
        List<ThunderUser> users = response['users'] != null ? response['users'].map<ThunderUser>((pv) => ThunderUser.fromLemmyUserView(pv)).toList() : [];
        List<ThunderPost> posts = response['posts'] != null ? response['posts'].map<ThunderPost>((pv) => ThunderPost.fromLemmyPostView(pv)).toList() : [];
        List<ThunderComment> comments = response['comments'] != null ? response['comments'].map<ThunderComment>((cv) => ThunderComment.fromLemmyCommentView(cv)).toList() : [];

        if (isValidUrl(query)) {
          final resolve = await lemmy.resolve(query: query);

          if (resolve['community'] != null) {
            communities.add(resolve['community']);
          } else if (resolve['user'] != null) {
            users.add(resolve['user']);
          } else if (resolve['post'] != null) {
            posts.add(resolve['post']);
          } else if (resolve['comment'] != null) {
            comments.add(resolve['comment']);
          }
        }

        return {
          'type': MetaSearchType.values.firstWhere((e) => e.searchType == response['type_']),
          'comments': comments,
          'posts': posts,
          'communities': communities,
          'users': users,
        };
      case ThreadiversePlatform.piefed:
        final piefed = _piefed!;
        final response = await piefed.search(
          query: query,
          type: type,
          sort: sort,
          listingType: listingType,
          limit: limit,
          page: page,
        );

        List<ThunderCommunity> communities = response['communities'] != null ? response['communities'].map<ThunderCommunity>((cv) => ThunderCommunity.fromPiefedCommunityView(cv)).toList() : [];
        List<ThunderUser> users = response['users'] != null ? response['users'].map<ThunderUser>((pv) => ThunderUser.fromPiefedUserView(pv)).toList() : [];
        List<ThunderPost> posts = response['posts'] != null ? response['posts'].map<ThunderPost>((pv) => ThunderPost.fromPiefedPostView(pv)).toList() : [];
        List<ThunderComment> comments = response['comments'] != null ? response['comments'].map<ThunderComment>((cv) => ThunderComment.fromPiefedCommentView(cv)).toList() : [];

        if (isValidUrl(query)) {
          final resolve = await piefed.resolve(query: query);

          if (resolve['community'] != null) {
            communities.add(resolve['community']);
          } else if (resolve['user'] != null) {
            users.add(resolve['user']);
          } else if (resolve['post'] != null) {
            posts.add(resolve['post']);
          } else if (resolve['comment'] != null) {
            comments.add(resolve['comment']);
          }
        }

        return {
          'type': MetaSearchType.values.firstWhere((e) => e.searchType == response['type_']),
          'posts': posts,
          'comments': comments,
          'communities': communities,
          'users': users,
        };
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<Map<String, dynamic>> resolve({required String query}) async {
    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await _lemmy!.resolve(query: query);
      case ThreadiversePlatform.piefed:
        return await _piefed!.resolve(query: query);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }
}
