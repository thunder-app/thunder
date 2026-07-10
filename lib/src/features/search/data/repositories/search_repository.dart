import 'package:thunder/src/core/core.dart';
import 'package:thunder/src/core/networking/resolved_api_client.dart';
import 'package:thunder/src/features/search/domain/models/search_results.dart';
import 'package:thunder/src/features/search/domain/models/search_resolve_result.dart';

/// Repository contract for search and resolve queries.
abstract class SearchRepository {
  /// Searches for posts, comments, users, communities, etc.
  Future<SearchResults> search({
    required String query,
    MetaSearchType? type,
    SearchSortType? sort,
    FeedListType? listingType,
    int? limit,
    int? page,
    int? communityId,
    int? creatorId,
    int? minimumUpvotes,
    bool? nsfw,
  });

  /// Resolves a given query
  Future<SearchResolveResult> resolve({required String query});
}

/// Implementation of [SearchRepository] using the unified API client
class SearchRepositoryImpl implements SearchRepository {
  /// The account to use for methods invoked in this repository
  final Account account;

  /// The API client to use for the repository
  final ResolvedApiClient _api;

  /// Kept for a consistent repository constructor surface across API-backed repos.
  // ignore: unused_field
  final LocalizationService _localization;

  /// Creates a new SearchRepositoryImpl.
  ///
  /// An optional [api] client and [localization] can be provided for testing.
  SearchRepositoryImpl({
    required this.account,
    ThunderApiClient? api,
    LocalizationService localization = const ThunderLocalizationService(),
  })  : _api = ResolvedApiClient(account: account, api: api),
        _localization = localization;

  @override
  Future<SearchResults> search({
    required String query,
    MetaSearchType? type,
    SearchSortType? sort,
    FeedListType? listingType,
    int? limit,
    int? page,
    int? communityId,
    int? creatorId,
    int? minimumUpvotes,
    bool? nsfw,
  }) async {
    final api = await _api.get();
    final response = await api.search(
      query: query,
      type: type,
      sort: sort,
      listingType: listingType,
      limit: limit,
      page: page,
      communityId: communityId,
      creatorId: creatorId,
      minimumUpvotes: minimumUpvotes,
      nsfw: nsfw,
    );

    // Lists are already parsed by the API client
    return SearchResults(
      type: response.type,
      comments: response.comments,
      posts: response.posts,
      communities: response.communities,
      users: response.users,
    );
  }

  @override
  Future<SearchResolveResult> resolve({required String query}) async {
    final api = await _api.get();
    final response = await api.resolve(query: query);

    return SearchResolveResult(
      community: response.community,
      post: response.post,
      comment: response.comment,
      user: response.user,
    );
  }
}
