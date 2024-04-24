import 'package:thunder/notification/enums/notification_type.dart';

class NotificationPayload {
  /// The type of notification
  final NotificationType type;

  /// A unique identifier for the inbox message that this notification corresponds to
  /// Can be null if this is a group
  final String? id;

  /// The identifier of the user to whom this notification was sent
  final String accountId;

  /// The inbox type of this notification
  final NotificationInboxType inboxType;

  /// Whether or not this notification is a group
  final bool group;

  NotificationPayload({
    required this.type,
    this.id,
    required this.accountId,
    required this.inboxType,
    required this.group,
  });

  NotificationPayload.fromJson(Map<String, dynamic> json)
      : type = NotificationType.values.byName(json['type'] as String),
        id = json['id'] as String?,
        accountId = json['accountId'] as String,
        inboxType = NotificationInboxType.values.byName(json['inboxType'] as String),
        group = json['group'] as bool;

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'id': id,
        'accountId': accountId,
        'inboxType': inboxType.name,
        'group': group,
      };
}

class NotificationGroupKey {
  /// Corresponds to the user that these notifications are for
  final String accountId;

  /// The type of inbox message
  final NotificationInboxType inboxType;

  NotificationGroupKey({required this.accountId, required this.inboxType});

  @override
  String toString() => '$accountId-$inboxType';
}
