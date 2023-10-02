part of 'community_bloc_old.dart';

abstract class CommunityEvent extends Equatable {
  const CommunityEvent();

  @override
  List<Object> get props => [];
}

class GetCommunityPostsEvent extends CommunityEvent {
  final bool reset;
  final SortType? sortType;
  final PostListingType? listingType;
  final int? communityId;
  final String? communityName;

  const GetCommunityPostsEvent({this.reset = false, this.sortType, this.listingType, this.communityId, this.communityName});
}

class VotePostEvent extends CommunityEvent {
  final int postId;
  final VoteType score;

  const VotePostEvent({required this.postId, required this.score});
}

class SavePostEvent extends CommunityEvent {
  final int postId;
  final bool save;

  const SavePostEvent({required this.postId, required this.save});
}

class ForceRefreshEvent extends CommunityEvent {}

class ChangeCommunitySubsciptionStatusEvent extends CommunityEvent {
  final int communityId;
  final bool follow;

  const ChangeCommunitySubsciptionStatusEvent({required this.communityId, required this.follow});
}

class CreatePostEvent extends CommunityEvent {
  final String name;
  final String body;
  final String? url;
  final bool nsfw;

  const CreatePostEvent({required this.name, required this.body, this.url, this.nsfw = false});
}

class MarkPostAsReadEvent extends CommunityEvent {
  final int postId;
  final bool read;

  const MarkPostAsReadEvent({required this.postId, required this.read});
}

class UpdatePostEvent extends CommunityEvent {
  final PostViewMedia postViewMedia;

  const UpdatePostEvent({required this.postViewMedia});
}

class BlockCommunityEvent extends CommunityEvent {
  final int communityId;
  final bool block;

  const BlockCommunityEvent({required this.communityId, this.block = false});
}

class DismissReadEvent extends CommunityEvent {
  const DismissReadEvent();
}
