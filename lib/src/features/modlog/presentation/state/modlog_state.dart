part of 'modlog_cubit.dart';

enum ModlogStatus { initial, fetching, success, failure }

@freezed
abstract class ModlogState with _$ModlogState {
  const factory ModlogState({
    /// The status of the modlog feed.
    @Default(ModlogStatus.initial) ModlogStatus status,

    /// The type of modlog action to filter by.
    @Default(ModlogActionType.all) ModlogActionType modlogActionType,

    /// A community ID to filter the modlog by.
    int? communityId,

    /// A user ID to filter the modlog by.
    int? userId,

    /// A moderator ID to filter the modlog by.
    int? moderatorId,

    /// A comment ID to filter the modlog by.
    int? commentId,

    /// The list of modlog events.
    @Default([]) List<ModlogEventItem> modlogEventItems,

    /// Whether the end of the modlog has been reached.
    @Default(false) bool hasReachedEnd,

    /// The current page of the modlog.
    @Default(1) int currentPage,

    /// The error message to display after a failure.
    String? message,
  }) = _ModlogState;

  const ModlogState._();

  AppErrorReason? get errorReason {
    final currentMessage = message;
    if (currentMessage == null || currentMessage.isEmpty) {
      return null;
    }
    return AppErrorReason.unexpected(message: currentMessage);
  }
}
