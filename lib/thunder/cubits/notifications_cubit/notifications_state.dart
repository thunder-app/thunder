part of 'notifications_cubit.dart';

enum NotificationsStatus { none, reply }

class NotificationsState extends Equatable {
  final NotificationsStatus status;
  final int? replyId;

  const NotificationsState({
    this.status = NotificationsStatus.none,
    this.replyId,
  });

  NotificationsState copyWith({
    required NotificationsStatus status,
    required int? replyId,
  }) {
    return NotificationsState(
      status: status,
      replyId: replyId,
    );
  }

  @override
  List<dynamic> get props => [
        status,
        replyId,
      ];
}
