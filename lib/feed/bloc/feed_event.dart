part of 'feed_bloc.dart';

sealed class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object> get props => [];
}

final class FeedFetchedEvent extends FeedEvent {
  /// The type of feed to display.
  final FeedType? feedType;

  /// The type of general feed to display: all, local, subscribed.
  final PostListingType? postListingType;

  /// The sorting to be applied to the feed.
  final SortType? sortType;

  /// The id of the community to display posts for.
  final int? communityId;

  /// The name of the community to display posts for.
  final String? communityName;

  /// The id of the user to display posts for.
  final int? userId;

  /// The username of the user to display posts for.
  final String? username;

  /// Boolean which indicates whether or not to reset the feed
  final bool reset;

  const FeedFetchedEvent({
    this.feedType,
    this.postListingType,
    this.sortType,
    this.communityId,
    this.communityName,
    this.userId,
    this.username,
    this.reset = false,
  });
}

final class FeedChangeSortTypeEvent extends FeedEvent {
  final SortType sortType;

  const FeedChangeSortTypeEvent(this.sortType);
}

final class ResetFeedEvent extends FeedEvent {}

final class FeedItemUpdatedEvent extends FeedEvent {
  final PostViewMedia postViewMedia;

  const FeedItemUpdatedEvent({required this.postViewMedia});
}

final class FeedCommunityViewUpdatedEvent extends FeedEvent {
  final CommunityView communityView;

  const FeedCommunityViewUpdatedEvent({required this.communityView});
}

final class FeedItemActionedEvent extends FeedEvent {
  /// This is the original PostViewMedia to perform the action upon. One of [postViewMedia] or [postId] must be provided
  /// If both are provided, [postId] will take precedence.
  final PostViewMedia? postViewMedia;

  /// This is the post id to perform the action upon. One of [postViewMedia] or [postId] must be provided
  /// If both are provided, [postId] will take precedence
  final int? postId;

  /// This indicates the relevant action to perform on the post
  final PostAction postAction;

  /// This indicates the value to assign the action to. It is of type dynamic to allow for any type
  /// TODO: Change the dynamic type to the correct type(s) if possible
  final dynamic value;

  const FeedItemActionedEvent({this.postViewMedia, this.postId, required this.postAction, this.value});
}

final class FeedClearMessageEvent extends FeedEvent {}

final class ScrollToTopEvent extends FeedEvent {}

final class FeedDismissReadEvent extends FeedEvent {}

final class FeedHidePostsFromViewEvent extends FeedEvent {
  final List<int> postIds;

  const FeedHidePostsFromViewEvent({required this.postIds});
}

final class CreatePostEvent extends FeedEvent {
  final int communityId;
  final String name;
  final String? body;
  final String? url;
  final bool? nsfw;

  const CreatePostEvent({required this.communityId, required this.name, this.body, this.url, this.nsfw});
}
