part of 'community_bloc.dart';

abstract class CommunityEvent extends Equatable {
  const CommunityEvent();

  @override
  List<Object> get props => [];
}

class GetCommunityPostsEvent extends CommunityEvent {
  final bool reset;
  final SortType? sortType;
  final ListingType? listingType;
  final int? communityId;

  const GetCommunityPostsEvent({this.reset = false, this.sortType, this.listingType, this.communityId});
}

class VotePostEvent extends CommunityEvent {
  final int postId;
  final int score;

  const VotePostEvent({required this.postId, required this.score});
}

class SavePostEvent extends CommunityEvent {
  final int postId;
  final bool save;

  const SavePostEvent({required this.postId, required this.save});
}

class ForceRefreshEvent extends CommunityEvent {}
<<<<<<< HEAD
=======

class ChangeCommunitySubsciptionStatusEvent extends CommunityEvent {
  final int communityId;
  final bool follow;

  const ChangeCommunitySubsciptionStatusEvent({required this.communityId, required this.follow});
}
>>>>>>> 43f111d9fe14159bd16fa9a4fc713ef08f62762a
