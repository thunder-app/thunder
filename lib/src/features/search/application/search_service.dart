import 'package:thunder/src/core/core.dart';
import 'package:thunder/src/features/post/post.dart';
import 'package:thunder/src/features/search/domain/models/search_results.dart';
import 'package:thunder/src/features/search/data/repositories/search_repository.dart';

/// Application service for composite search behavior.
class SearchService {
  /// Creates a [SearchService] backed by [searchRepository].
  SearchService({required SearchRepository searchRepository}) : _searchRepository = searchRepository;

  final SearchRepository _searchRepository;

  /// Searches for posts, comments, users, communities, etc.
  ///
  /// When [query] is a URL, also resolves it and merges any matching entity into the results.
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
    final response = await _searchRepository.search(
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

    if (!isValidUrl(query)) {
      return SearchResults(
        type: response.type,
        comments: response.comments,
        posts: await parsePosts(response.posts),
        communities: response.communities,
        users: response.users,
      );
    }

    final resolveResponse = await _searchRepository.resolve(query: query);

    final communities = List<ThunderCommunity>.from(response.communities);
    final users = List<ThunderUser>.from(response.users);
    final posts = List<ThunderPost>.from(response.posts);
    final comments = List<ThunderComment>.from(response.comments);

    if (resolveResponse.community != null) {
      communities.add(resolveResponse.community!);
    } else if (resolveResponse.user != null) {
      users.add(resolveResponse.user!);
    } else if (resolveResponse.post != null) {
      posts.add(resolveResponse.post!);
    } else if (resolveResponse.comment != null) {
      comments.add(resolveResponse.comment!);
    }

    return SearchResults(
      type: response.type,
      comments: comments,
      posts: await parsePosts(posts),
      communities: communities,
      users: users,
    );
  }
}
