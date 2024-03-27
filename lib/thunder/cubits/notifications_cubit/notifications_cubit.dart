import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:thunder/utils/notifications/notifications.dart';

part 'notifications_state.dart';

/// A cubit for handling notifications
class NotificationsCubit extends Cubit<NotificationsState> {
  final Stream<NotificationResponse> notificationsStream;
  StreamSubscription<NotificationResponse>? _notificationsStreamSubscription;

  NotificationsCubit({required this.notificationsStream}) : super(const NotificationsState());

  void handleNotifications() {
    _notificationsStreamSubscription = notificationsStream.listen((notificationResponse) async {
      // Check if this is a reply notification
      if (notificationResponse.payload?.contains(repliesGroupKey) == true) {
        // Check if this is a specific notification for a specific reply
        int? replyId;
        final List<String> parts = notificationResponse.payload!.split('-');
        if (parts.length == 2) {
          replyId = int.tryParse(parts[1]);
        }

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
