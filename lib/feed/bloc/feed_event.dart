part of 'feed_bloc.dart';

sealed class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object> get props => [];
}

final class FeedFetched extends FeedEvent {
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

  const FeedFetched({
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

final class ResetFeed extends FeedEvent {}

final class FeedItemUpdated extends FeedEvent {
  final PostViewMedia postViewMedia;

  const FeedItemUpdated({required this.postViewMedia});
}
