part of 'notifications_cubit.dart';

enum NotificationsStatus { none, reply }

class NotificationsState extends Equatable {
  final NotificationsStatus status;
  final int? replyId;
  final String? accountId;

  const NotificationsState({
    this.status = NotificationsStatus.none,
    this.replyId,
    this.accountId,
  });

  NotificationsState copyWith({
    required NotificationsStatus status,
    required int? replyId,
    required String? accountId,
  }) {
    return NotificationsState(
      status: status,
      replyId: replyId,
      accountId: accountId,
    );
  }

  @override
  List<dynamic> get props => [
        status,
        replyId,
        accountId,
      ];
}
