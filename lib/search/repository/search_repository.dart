import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/enums/feed_list_type.dart';
import 'package:thunder/core/enums/meta_search_type.dart';
import 'package:thunder/core/enums/post_sort_type.dart';
import 'package:thunder/account/account.dart';

/// Interface for a search repository
abstract class SearchRepository {
  /// Searches for posts, comments, users, communities, etc.
  /// @TODO: Change the return type to an internal model
  Future<SearchResponse> search({
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
  Future<ResolveObjectResponse> resolve({required String query});
}

/// Implementation of [SearchRepository] using Lemmy API
class LemmySearchRepository implements SearchRepository {
  /// The account to use for methods invoked in this repository
  Account account;

  /// The Lemmy client to use for the repository
  late LemmyApiV3 client;

  LemmySearchRepository({required this.account}) {
    client = LemmyApiV3(account.instance, debug: kDebugMode);
  }

  @override
  Future<SearchResponse> search({
    required String query,
    MetaSearchType? type,
    PostSortType? sort,
    FeedListType? listingType,
    int? limit,
    int? page,
    int? communityId,
    int? creatorId,
  }) async {
    final response = await client.run(Search(
      auth: account.jwt,
      q: query,
      type: type?.toLemmyType(),
      sort: sort?.toLemmyType(),
      listingType: listingType?.toLemmyType(),
      limit: limit,
      page: page,
      communityId: communityId,
      creatorId: creatorId,
    ));

    return response;
  }

  @override
  Future<ResolveObjectResponse> resolve({required String query}) async {
    return await client.run(ResolveObject(q: query));
  }
}
