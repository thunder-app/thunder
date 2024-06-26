import 'package:thunder/notification/enums/notification_type.dart';

class NotificationPayload {
  /// The type of notification
  final NotificationType type;

  /// A unique identifier for the inbox message that this notification corresponds to
  /// Can be null if this is a group
  final int? id;

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
        id = json['id'] as int?,
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

/// Represents the payload generated by the Thunder server for UnifiedPush notifications for replies
class SlimCommentReplyView {
  int commentReplyId;
  String commentContent;
  bool commentRemoved;
  bool commentDeleted;
  String creatorName;
  String creatorActorId;
  String postName;
  String communityName;
  String communityActorId;
  String recipientName;
  String recipientActorId;

  SlimCommentReplyView({
    required this.commentReplyId,
    required this.commentContent,
    required this.commentRemoved,
    required this.commentDeleted,
    required this.creatorName,
    required this.creatorActorId,
    required this.postName,
    required this.communityName,
    required this.communityActorId,
    required this.recipientName,
    required this.recipientActorId,
  });

  factory SlimCommentReplyView.fromJson(Map<String, dynamic> json) {
    return SlimCommentReplyView(
      commentReplyId: json['comment_reply_id'],
      commentContent: json['comment_content'],
      commentRemoved: json['comment_removed'],
      commentDeleted: json['comment_deleted'],
      creatorName: json['creator_name'],
      creatorActorId: json['creator_actor_id'],
      postName: json['post_name'],
      communityName: json['community_name'],
      communityActorId: json['community_actor_id'],
      recipientName: json['recipient_name'],
      recipientActorId: json['recipient_actor_id'],
    );
  }
}
