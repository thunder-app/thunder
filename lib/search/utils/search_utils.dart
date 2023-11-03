import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/search/bloc/search_bloc.dart';

/// Checks whether there are any results for the current given [searchType] in the [searchState] or the given [searchResponse].
bool searchIsEmpty(SearchType searchType, {SearchState? searchState, SearchResponse? searchResponse}) {
  assert(searchState != null || searchResponse != null);

  final List<CommunityView>? communities = searchState?.communities ?? searchResponse?.communities;
  final List<PersonView>? users = searchState?.users ?? searchResponse?.users;
  final List<CommentView>? comments = searchState?.comments ?? searchResponse?.comments;
  final List<PostView>? posts = searchState?.posts?.map((pvm) => pvm.postView).toList() ?? searchResponse?.posts;

  return switch (searchType) {
    SearchType.communities => communities?.isNotEmpty != true,
    SearchType.users => users?.isNotEmpty != true,
    SearchType.comments => comments?.isNotEmpty != true,
    SearchType.posts => posts?.isNotEmpty != true,
    //SearchType.url => TODO
    _ => false,
  };
}
