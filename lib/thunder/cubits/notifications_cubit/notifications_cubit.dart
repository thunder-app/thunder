import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:thunder/notification/enums/notification_type.dart';

import 'package:thunder/notification/shared/notification_payload.dart';

part 'notifications_state.dart';

/// A cubit for handling notifications
class NotificationsCubit extends Cubit<NotificationsState> {
  final Stream<NotificationResponse> notificationsStream;
  StreamSubscription<NotificationResponse>? _notificationsStreamSubscription;

  NotificationsCubit({required this.notificationsStream}) : super(const NotificationsState());

  void handleNotifications() {
    _notificationsStreamSubscription = notificationsStream.listen((notificationResponse) async {
      NotificationPayload? payload = notificationResponse.payload?.isNotEmpty == true ? NotificationPayload.fromJson(jsonDecode(notificationResponse.payload!)) : null;

      // Check if this is a reply notification
      if (payload?.inboxType == NotificationInboxType.reply) {
        emit(state.copyWith(status: NotificationsStatus.reply, replyId: payload!.id, accountId: payload.accountId));
      }

      // Reset the state
      emit(state.copyWith(status: NotificationsStatus.none, replyId: null, accountId: payload?.accountId));
    });
  }

  void dispose() {
    _notificationsStreamSubscription?.cancel();
  }
}
