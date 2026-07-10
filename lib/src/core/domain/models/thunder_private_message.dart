import 'package:thunder/src/core/domain/models/notification_ref.dart';
import 'package:thunder/src/core/domain/models/thunder_user.dart';

class ThunderPrivateMessage {
  /// The private message id on its home instance.
  final int id;

  /// ID of the sender, when provided.
  final int? creatorId;

  /// ID of the recipient, when provided.
  final int? recipientId;

  /// Platform conversation ID, when supported.
  final int? conversationId;

  /// Markdown message content.
  final String content;

  /// Whether the message was deleted.
  final bool deleted;

  /// When the message was sent.
  final DateTime published;

  /// Recipient details, when they were included with the response.
  final ThunderUser? recipient;

  /// Sender details, when they were included with the response.
  final ThunderUser? creator;

  /// Inbox details used for read state.
  final NotificationRef? notification;

  ThunderPrivateMessage({
    required this.id,
    this.creatorId,
    this.recipientId,
    this.conversationId,
    required this.content,
    required this.deleted,
    required this.published,
    this.recipient,
    this.creator,
    this.notification,
  });

  ThunderPrivateMessage copyWith({
    int? id,
    int? creatorId,
    int? recipientId,
    int? conversationId,
    String? content,
    bool? deleted,
    DateTime? published,
    ThunderUser? recipient,
    ThunderUser? creator,
    NotificationRef? notification,
  }) {
    return ThunderPrivateMessage(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      recipientId: recipientId ?? this.recipientId,
      conversationId: conversationId ?? this.conversationId,
      content: content ?? this.content,
      deleted: deleted ?? this.deleted,
      published: published ?? this.published,
      recipient: recipient ?? this.recipient,
      creator: creator ?? this.creator,
      notification: notification ?? this.notification,
    );
  }
}
