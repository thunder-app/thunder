part of 'notifications_cubit.dart';

enum NotificationsStatus { none, reply, mention, message }

const _notificationsUnset = Object();

class NotificationsState extends Equatable {
  /// The status of the notification.
  final NotificationsStatus status;

  /// The ID of the notification (reply, mention, or message).
  final int? notificationId;

  /// The account ID associated with the notification.
  final String? accountId;

  /// Whether the notification is pending navigation (waiting for account switch to complete).
  final bool pending;

  const NotificationsState({this.status = NotificationsStatus.none, this.notificationId, this.accountId, this.pending = false});

  NotificationsState copyWith({NotificationsStatus? status, Object? notificationId = _notificationsUnset, Object? accountId = _notificationsUnset, bool? pending}) {
    return NotificationsState(
      status: status ?? this.status,
      notificationId: identical(notificationId, _notificationsUnset) ? this.notificationId : notificationId as int?,
      accountId: identical(accountId, _notificationsUnset) ? this.accountId : accountId as String?,
      pending: pending ?? this.pending,
    );
  }

  /// Clears the notification state.
  NotificationsState clear() {
    return const NotificationsState(status: NotificationsStatus.none, notificationId: null, accountId: null, pending: false);
  }

  @override
  List<Object?> get props => [status, notificationId, accountId, pending];
}
