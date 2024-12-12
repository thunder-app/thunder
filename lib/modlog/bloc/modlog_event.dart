part of 'modlog_bloc.dart';

sealed class ModlogEvent extends Equatable {
  const ModlogEvent();

  @override
  List<Object> get props => [];
}

/// Event for resetting the modlog
final class ResetModlogEvent extends ModlogEvent {}

/// Event for fetching the modlog feed
final class ModlogFeedFetchedEvent extends ModlogEvent {
  /// The filtering to be applied to the feed.
  final ModlogActionType? modlogActionType;

  /// The id of the community to display posts for.
  final int? communityId;

  /// The id of the user to display posts for.
  final int? userId;

  /// The id of the moderator to display posts for.
  final int? moderatorId;

  /// The id of a specific comment to show in the modlog (optional)
  final int? commentId;

  /// Boolean which indicates whether or not to reset the feed
  final bool reset;

  const ModlogFeedFetchedEvent({
    this.modlogActionType = ModlogActionType.all,
    this.communityId,
    this.userId,
    this.moderatorId,
    this.commentId,
    this.reset = false,
  });
}

/// Event for changing the filter type of the modlog feed
final class ModlogFeedChangeFilterTypeEvent extends ModlogEvent {
  final ModlogActionType modlogActionType;

  const ModlogFeedChangeFilterTypeEvent({required this.modlogActionType});
}

/// Event for clearing the modlog feed snackbar message
final class ModlogFeedClearMessageEvent extends ModlogEvent {}
