part of 'feed_bloc.dart';

sealed class FeedActionInput extends Equatable {
  const FeedActionInput();

  @override
  List<Object?> get props => [];
}

final class VotePostInput extends FeedActionInput {
  const VotePostInput(this.score);

  final int score;

  @override
  List<Object?> get props => [score];
}

final class SavePostInput extends FeedActionInput {
  const SavePostInput(this.save);

  final bool save;

  @override
  List<Object?> get props => [save];
}

final class ReadPostInput extends FeedActionInput {
  const ReadPostInput(this.read);

  final bool read;

  @override
  List<Object?> get props => [read];
}

final class MultiReadPostInput extends FeedActionInput {
  const MultiReadPostInput(this.read);

  final bool read;

  @override
  List<Object?> get props => [read];
}

final class HidePostInput extends FeedActionInput {
  const HidePostInput(this.hide);

  final bool hide;

  @override
  List<Object?> get props => [hide];
}

final class DeletePostInput extends FeedActionInput {
  const DeletePostInput(this.delete);

  final bool delete;

  @override
  List<Object?> get props => [delete];
}

final class ReportPostInput extends FeedActionInput {
  const ReportPostInput(this.reason);

  final String reason;

  @override
  List<Object?> get props => [reason];
}

final class LockPostInput extends FeedActionInput {
  const LockPostInput(this.lock);

  final bool lock;

  @override
  List<Object?> get props => [lock];
}

final class PinCommunityPostInput extends FeedActionInput {
  const PinCommunityPostInput(this.pin);

  final bool pin;

  @override
  List<Object?> get props => [pin];
}

final class RemovePostInput extends FeedActionInput {
  const RemovePostInput({
    required this.remove,
    required this.reason,
  });

  final bool remove;
  final String reason;

  @override
  List<Object?> get props => [remove, reason];
}

sealed class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

final class FeedFetchedEvent extends FeedEvent {
  /// The type of feed to display.
  final FeedType? feedType;

  /// The subtype of feed to display (if applicable). This is only used when [feedType] is [FeedType.user]
  final FeedTypeSubview feedTypeSubview;

  /// The type of general feed to display: all, local, subscribed.
  final FeedListType? feedListType;

  /// The sorting to be applied to the feed.
  final PostSortType? postSortType;

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

  /// Indicates whether to show hidden posts in the feed
  final bool showHidden;

  /// Indicates whether to show saved posts/comments in the feed
  final bool showSaved;

  const FeedFetchedEvent({
    this.feedType,
    this.feedTypeSubview = FeedTypeSubview.post,
    this.feedListType,
    this.postSortType,
    this.communityId,
    this.communityName,
    this.userId,
    this.username,
    this.reset = false,
    this.showHidden = false,
    this.showSaved = false,
  });

  @override
  List<Object?> get props => [feedType, feedTypeSubview, feedListType, postSortType, communityId, communityName, userId, username, reset, showHidden, showSaved];
}

final class FeedChangePostSortTypeEvent extends FeedEvent {
  final PostSortType postSortType;

  const FeedChangePostSortTypeEvent(this.postSortType);

  @override
  List<Object?> get props => [postSortType];
}

final class ResetFeedEvent extends FeedEvent {
  /// Whether or not to soft reset the feed. A soft reset will only reset the feed, but not the user/community information or the feed status
  final bool softReset;

  const ResetFeedEvent({this.softReset = false});

  @override
  List<Object?> get props => [softReset];
}

final class FeedItemUpdatedEvent extends FeedEvent {
  final ThunderPost post;

  const FeedItemUpdatedEvent({required this.post});

  @override
  List<Object?> get props => [post];
}

final class FeedCommunityUpdatedEvent extends FeedEvent {
  final ThunderCommunity community;

  const FeedCommunityUpdatedEvent({required this.community});

  @override
  List<Object?> get props => [community];
}

final class FeedItemActionedEvent extends FeedEvent {
  /// This is the original ThunderPost to perform the action upon. One of [post] or [postId] must be provided
  /// If both are provided, [postId] will take precedence.
  final ThunderPost? post;

  /// This is the post id to perform the action upon. One of [post] or [postId] must be provided
  /// If both are provided, [postId] will take precedence
  final int? postId;

  final List<int>? postIds;

  /// This indicates the relevant action to perform on the post
  final PostAction postAction;

  /// Typed payload for the selected [postAction].
  final FeedActionInput? actionInput;

  const FeedItemActionedEvent({
    this.post,
    this.postId,
    this.postIds,
    required this.postAction,
    this.actionInput,
  });

  @override
  List<Object?> get props => [post, postId, postIds, postAction, actionInput];
}

final class FeedClearMessageEvent extends FeedEvent {}

final class ScrollToTopEvent extends FeedEvent {}

final class FeedDismissReadEvent extends FeedEvent {}

final class FeedDismissBlockedEvent extends FeedEvent {
  final int? communityId;
  final int? userId;

  const FeedDismissBlockedEvent({this.communityId, this.userId});

  @override
  List<Object?> get props => [communityId, userId];
}

final class FeedDismissHiddenPostEvent extends FeedEvent {
  final int postId;

  const FeedDismissHiddenPostEvent({required this.postId});

  @override
  List<Object?> get props => [postId];
}

final class FeedHidePostsFromViewEvent extends FeedEvent {
  final List<int> postIds;

  const FeedHidePostsFromViewEvent({required this.postIds});

  @override
  List<Object?> get props => [postIds];
}

final class CreatePostEvent extends FeedEvent {
  final int communityId;
  final String name;
  final String? body;
  final String? url;
  final bool? nsfw;

  const CreatePostEvent({required this.communityId, required this.name, this.body, this.url, this.nsfw});

  @override
  List<Object?> get props => [communityId, name, body, url, nsfw];
}

final class PopulatePostsEvent extends FeedEvent {
  final List<ThunderPost> posts;

  const PopulatePostsEvent(this.posts);

  @override
  List<Object?> get props => [posts];
}
