import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:thunder/src/core/enums/feed_list_type.dart';
import 'package:thunder/src/core/enums/meta_search_type.dart';
import 'package:thunder/src/core/enums/search_sort_type.dart';
import 'package:thunder/src/core/network/api_client_factory.dart';
import 'package:thunder/src/core/network/thunder_api_client.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/comment/comment.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/shared/utils/links.dart';

/// Interface for a search repository
abstract class SearchRepository {
  /// Searches for posts, comments, users, communities, etc.
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
  final Account account;

  /// The API client to use for the repository
  final ThunderApiClient _api;

  /// Creates a new SearchRepositoryImpl.
  ///
  /// An optional [api] client can be provided for testing.
  SearchRepositoryImpl({required this.account, ThunderApiClient? api}) : _api = api ?? ApiClientFactory.create(account, debug: kDebugMode);

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
    final response = await _api.search(
      query: query,
      type: type,
      sort: sort,
      listingType: listingType,
      limit: limit,
      page: page,
      communityId: communityId,
      creatorId: creatorId,
    );

    // Lists are already parsed by the API client
    List<ThunderCommunity> communities = response.communities;
    List<ThunderUser> users = response.users;
    List<ThunderPost> posts = response.posts;
    List<ThunderComment> comments = response.comments;

    // Try to resolve if the query is a URL
    if (isValidUrl(query)) {
      final resolveResponse = await _api.resolve(query: query);
      if (resolveResponse.community != null) {
        communities.add(resolveResponse.community!);
      } else if (resolveResponse.user != null) {
        users.add(resolveResponse.user!);
      } else if (resolveResponse.post != null) {
        posts.add(resolveResponse.post!);
      } else if (resolveResponse.comment != null) {
        comments.add(resolveResponse.comment!);
      }
    }

    return {
      'type': response.type,
      'comments': comments,
      'posts': posts,
      'communities': communities,
      'users': users,
    };
  }

  @override
  Future<Map<String, dynamic>> resolve({required String query}) async {
    final response = await _api.resolve(query: query);
    return {
      'community': response.community,
      'post': response.post,
      'comment': response.comment,
      'person': response.user,
    };
  }
}
