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
      // Check if this is a reply notification
      NotificationPayload? payload = notificationResponse.payload?.isNotEmpty == true ? NotificationPayload.fromJson(jsonDecode(notificationResponse.payload!)) : null;
      if (payload?.inboxType == NotificationInboxType.reply) {
        // Check if this is a specific notification for a specific reply
        int? replyId = int.tryParse(payload!.id ?? '');

        emit(state.copyWith(status: NotificationsStatus.reply, replyId: replyId));
      }

      // Reset the state
      emit(state.copyWith(status: NotificationsStatus.none, replyId: null));
    });
  }

  void dispose() {
    _notificationsStreamSubscription?.cancel();
  }
}
