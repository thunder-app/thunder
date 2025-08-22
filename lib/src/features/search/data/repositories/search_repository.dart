import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:thunder/src/core/network/lemmy_api.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/core/network/piefed_api.dart';
import 'package:thunder/src/core/enums/feed_list_type.dart';
import 'package:thunder/src/core/enums/meta_search_type.dart';
import 'package:thunder/src/core/enums/post_sort_type.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/core/enums/threadiverse_platform.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/user/user.dart';

/// Interface for a search repository
abstract class SearchRepository {
  /// Searches for posts, comments, users, communities, etc.
  /// @TODO: Change the return type to an internal model
  Future<Map<String, dynamic>> search({
    required String query,
    MetaSearchType? type,
    PostSortType? sort,
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

  /// The Lemmy client to use for the repository
  late LemmyApi lemmy;

  /// The Piefed client to use for the repository
  late PiefedApi piefed;

  SearchRepositoryImpl({required this.account}) {
    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        lemmy = LemmyApi(account: account, debug: kDebugMode);
        break;
      case ThreadiversePlatform.piefed:
        piefed = PiefedApi(account: account, debug: kDebugMode);
        break;
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<Map<String, dynamic>> search({
    required String query,
    MetaSearchType? type,
    PostSortType? sort,
    FeedListType? listingType,
    int? limit,
    int? page,
    int? communityId,
    int? creatorId,
  }) async {
    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
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

        return {
          'type': MetaSearchType.values.firstWhere((e) => e.searchType == response['type_']),
          'comments': response['comments'].map<ThunderComment>((cv) => ThunderComment.fromLemmyCommentView(cv)).toList(),
          'posts': response['posts'].map<ThunderPost>((pv) => ThunderPost.fromLemmyPostView(pv)).toList(),
          'communities': response['communities'].map<ThunderCommunity>((cv) => ThunderCommunity.fromLemmyCommunityView(cv)).toList(),
          'users': response['users'].map<ThunderUser>((pv) => ThunderUser.fromLemmyUserView(pv)).toList(),
        };
      case ThreadiversePlatform.piefed:
        final response = await piefed.search(
          query: query,
          type: type,
          sort: sort,
          listingType: listingType,
          limit: limit,
          page: page,
        );

        return {
          'type': MetaSearchType.values.firstWhere((e) => e.searchType == response['type_']),
          'posts': response['posts'].map<ThunderPost>((pv) => ThunderPost.fromPiefedPostView(pv)).toList(),
          'comments': <ThunderComment>[],
          'communities': response['communities'].map<ThunderCommunity>((cv) => ThunderCommunity.fromPiefedCommunityView(cv)).toList(),
          'users': response['users'].map<ThunderUser>((pv) => ThunderUser.fromPiefedUserView(pv)).toList(),
        };
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<Map<String, dynamic>> resolve({required String query}) async {
    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await lemmy.resolve(query: query);
      case ThreadiversePlatform.piefed:
        return await piefed.resolve(query: query);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }
}
