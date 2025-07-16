import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/comment/models/thunder_comment.dart';

import 'package:thunder/community/models/thunder_community.dart';
import 'package:thunder/core/enums/meta_search_type.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/post/models/thunder_post.dart';
import 'package:thunder/search/bloc/search_bloc.dart';

/// Checks whether there are any results for the current given [searchType] in the [searchState] or the given [searchResponse].
bool searchIsEmpty(MetaSearchType searchType, {SearchState? searchState, SearchResponse? searchResponse}) {
  final List<ThunderCommunity>? communities = searchState?.communities ?? searchResponse?.communities.map((cv) => ThunderCommunity.fromLemmyCommunityView(cv.toJson())).toList();
  final List<PersonView>? users = searchState?.users ?? searchResponse?.users;
  final List<ThunderComment>? comments = searchState?.comments ?? searchResponse?.comments.map((cv) => ThunderComment.fromLemmyCommentView(cv.toJson())).toList();
  final List<ThunderPost>? posts = searchState?.posts?.map((post) => post).toList() ?? searchResponse?.posts.map((pv) => ThunderPost.fromLemmyPostView(pv.toJson())).toList();
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
