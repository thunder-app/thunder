import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:thunder/src/features/notification/notification.dart';

part 'notifications_state.dart';

/// A cubit for handling notifications
class NotificationsCubit extends Cubit<NotificationsState> {
  final Stream<NotificationResponse> notificationsStream;

  StreamSubscription<NotificationResponse>? _notificationsStreamSubscription;

  NotificationsCubit({required this.notificationsStream}) : super(const NotificationsState());

  void handleNotifications() {
    if (_notificationsStreamSubscription != null) return; // Only set up the listener once - the stream is single-subscription

    _notificationsStreamSubscription = notificationsStream.listen((notificationResponse) async {
      final payload = notificationResponse.payload?.isNotEmpty == true ? NotificationPayload.fromJson(jsonDecode(notificationResponse.payload!)) : null;

      if (payload == null) return;

      // Map notification inbox type to status
      final status = switch (payload.inboxType) {
        NotificationInboxType.reply => NotificationsStatus.reply,
        NotificationInboxType.mention => NotificationsStatus.mention,
        NotificationInboxType.message => NotificationsStatus.message,
      };

      emit(state.copyWith(status: status, notificationId: payload.id, accountId: payload.accountId, pending: false));
    });
  }

  /// Marks the notification as pending. This is used when we need to switch accounts before navigating to the notification.
  void setPending() {
    emit(state.copyWith(pending: true));
  }

  /// Clears the notification state after navigation is complete
  void clearNotification() {
    emit(state.clear());
  }

  void dispose() {
    _notificationsStreamSubscription?.cancel();
  }
}
