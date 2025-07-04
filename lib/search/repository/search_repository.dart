import 'dart:async';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/core/enums/feed_list_type.dart';
import 'package:thunder/core/enums/post_sort_type.dart';
import 'package:thunder/account/account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';

/// Interface for a search repository
abstract class SearchRepository {
  /// Searches for posts, comments, users, communities, etc.
  /// @TODO: Change the return type to an internal model
  Future<SearchResponse> search({
    required String query,
    SearchType? type,
    PostSortType? sort,
    FeedListType? listingType,
    int? limit,
    int? page,
    int? communityId,
    int? creatorId,
  });

  /// Resolves a given query
  Future<ResolveObjectResponse> resolve({required String query});

  /// Dispose method to clean up resources
  void dispose();
}

/// Implementation of [SearchRepository] using Lemmy API
class LemmySearchRepository implements SearchRepository {
  /// The Lemmy client to use for the repository
  LemmyApiV3 client;

  /// Stream subscription for client changes
  StreamSubscription<LemmyApiV3>? _subscription;

  LemmySearchRepository({required this.client}) {
    _subscription = LemmyClient.onClientChanged.listen((newClient) => client = newClient);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  Future<SearchResponse> search({
    required String query,
    SearchType? type,
    PostSortType? sort,
    FeedListType? listingType,
    int? limit,
    int? page,
    int? communityId,
    int? creatorId,
  }) async {
    final account = await fetchActiveProfile();

    final response = await client.run(Search(
      auth: account.jwt,
      q: query,
      type: type,
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
