import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/search/search.dart';

/// Checks whether there are any results for the current given [searchType] in the [searchState] or the given [searchResponse].
bool searchIsEmpty(MetaSearchType searchType, {SearchState? searchState, SearchResults? searchResponse}) {
  final List<ThunderCommunity>? communities = searchState?.communities ?? searchResponse?.communities;
  final List<ThunderUser>? users = searchState?.users ?? searchResponse?.users;
  final List<ThunderComment>? comments = searchState?.comments ?? searchResponse?.comments;
  final List<ThunderPost>? posts = searchState?.posts ?? searchResponse?.posts;
  final List<ThunderInstanceInfo>? instances = searchState?.instances;

  return switch (searchType) {
    MetaSearchType.communities => communities?.isNotEmpty != true,
    MetaSearchType.users => users?.isNotEmpty != true,
    MetaSearchType.comments => comments?.isNotEmpty != true,
    MetaSearchType.posts => posts?.isNotEmpty != true,
    MetaSearchType.url => posts?.isNotEmpty != true,
    MetaSearchType.instances => instances?.isNotEmpty != true,
    _ => false,
  };
}
