part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class StartSearchEvent extends SearchEvent {
  final String query;
  final SortType sortType;
  final ListingType listingType;
  final MetaSearchType searchType;
  final int? communityId;
  final int? creatorId;
  final List<CommunityView>? favoriteCommunities;
  final bool? force;

  const StartSearchEvent({
    required this.query,
    required this.sortType,
    required this.listingType,
    required this.searchType,
    this.communityId,
    this.creatorId,
    this.favoriteCommunities,
    this.force,
  });
}

class ChangeCommunitySubsciptionStatusEvent extends SearchEvent {
  final int communityId;
  final bool follow;
  final String query;

  const ChangeCommunitySubsciptionStatusEvent({required this.communityId, required this.follow, required this.query});
}

class ResetSearch extends SearchEvent {}

class ContinueSearchEvent extends SearchEvent {
  final String query;
  final SortType sortType;
  final ListingType listingType;
  final MetaSearchType searchType;
  final int? communityId;
  final int? creatorId;
  final List<CommunityView>? favoriteCommunities;

  const ContinueSearchEvent({
    required this.query,
    required this.sortType,
    required this.listingType,
    required this.searchType,
    this.communityId,
    this.creatorId,
    this.favoriteCommunities,
  });
}

class FocusSearchEvent extends SearchEvent {}

class GetTrendingCommunitiesEvent extends SearchEvent {}

class VoteCommentEvent extends SearchEvent {
  final int commentId;
  final int score;

  const VoteCommentEvent({required this.commentId, required this.score});
}

class SaveCommentEvent extends SearchEvent {
  final int commentId;
  final bool save;

  const SaveCommentEvent({required this.commentId, required this.save});
}
