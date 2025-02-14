import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/core/enums/meta_search_type.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/search/bloc/search_bloc.dart';
import 'package:thunder/utils/convert.dart';
import 'package:thunder/utils/instance.dart';

/// Checks whether there are any results for the current given [searchType] in the [searchState] or the given [searchResponse].
bool searchIsEmpty(MetaSearchType searchType, {SearchState? searchState, SearchResponse? searchResponse}) {
  final List<CommunityView>? communities = searchState?.communities?.map((cv) => convertToCommunityView(cv)!).toList() ?? searchResponse?.communities.map((cv) => convertToCommunityView(cv)!).toList();
  final List<PersonView>? users = searchState?.users ?? searchResponse?.users;
  final List<CommentView>? comments = searchState?.comments ?? searchResponse?.comments;
  final List<PostView>? posts = searchState?.posts?.map((pvm) => pvm.postView).toList() ?? searchResponse?.posts;
  final List<GetInstanceInfoResponse>? instances = searchState?.instances;

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
