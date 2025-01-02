part of 'modlog_bloc.dart';

enum ModlogStatus { initial, fetching, success, failure }

final class ModlogState extends Equatable {
  const ModlogState({
    this.status = ModlogStatus.initial,
    this.modlogActionType = ModlogActionType.all,
    this.communityId,
    this.userId,
    this.moderatorId,
    this.commentId,
    this.modlogEventItems = const <ModlogEventItem>[],
    this.hasReachedEnd = false,
    this.currentPage = 1,
    this.message,
  });

  /// The status of the modlog feed
  final ModlogStatus status;

  /// The filtering to be applied to the feed.
  final ModlogActionType? modlogActionType;

  /// The id of the community to display modlog events for.
  final int? communityId;

  /// The id of the user to display modlog events for.
  final int? userId;

  /// The id of the moderator to display modlog events for.
  final int? moderatorId;

  /// The id of a specific comment to show in the modlog (optional)
  final int? commentId;

  /// The list of modlog events
  final List<ModlogEventItem> modlogEventItems;

  /// Determines if we have reached the end of the modlog feed
  final bool hasReachedEnd;

  /// The current page of the feed
  final int currentPage;

  /// The message to display on failure
  final String? message;

  ModlogState copyWith({
    ModlogStatus? status,
    ModlogActionType? modlogActionType,
    int? communityId,
    int? userId,
    int? moderatorId,
    int? commentId,
    List<ModlogEventItem>? modlogEventItems,
    bool? hasReachedEnd,
    int? currentPage,
    String? message,
  }) {
    return ModlogState(
      status: status ?? this.status,
      modlogActionType: modlogActionType ?? this.modlogActionType,
      communityId: communityId ?? this.communityId,
      userId: userId ?? this.userId,
      moderatorId: moderatorId ?? this.moderatorId,
      commentId: commentId ?? this.commentId,
      modlogEventItems: modlogEventItems ?? this.modlogEventItems,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      currentPage: currentPage ?? this.currentPage,
      message: message ?? this.message,
    );
  }

  @override
  String toString() {
    return '''ModlogState { status: $status, modlogActionType: $modlogActionType, communityId: $communityId, userId: $userId, moderatorId: $moderatorId, commentId: $commentId, modlogEventItems: ${modlogEventItems.length}, hasReachedEnd: $hasReachedEnd }''';
  }

  @override
  List<dynamic> get props => [status, modlogActionType, communityId, userId, moderatorId, commentId, modlogEventItems, hasReachedEnd, currentPage, message];
}
