part of 'modlog_bloc.dart';

sealed class ModlogEvent extends Equatable {
  const ModlogEvent();

  @override
  List<Object> get props => [];
}

final class ResetModlogEvent extends ModlogEvent {}

final class ModlogFeedFetchedEvent extends ModlogEvent {
  /// The filtering to be applied to the feed.
  final ModlogActionType? modlogActionType;

  /// The id of the community to display posts for.
  final int? communityId;

  /// The id of the user to display posts for.
  final int? userId;

  /// The id of the moderator to display posts for.
  final int? moderatorId;

  /// Boolean which indicates whether or not to reset the feed
  final bool reset;

  const ModlogFeedFetchedEvent({
    this.modlogActionType = ModlogActionType.all,
    this.communityId,
    this.userId,
    this.moderatorId,
    this.reset = false,
  });
}

final class ModlogFeedChangeFilterTypeEvent extends ModlogEvent {
  final ModlogActionType modlogActionType;

  const ModlogFeedChangeFilterTypeEvent({required this.modlogActionType});
}

final class ModlogFeedClearMessageEvent extends ModlogEvent {}

final class ScrollToTopEvent extends ModlogEvent {}
