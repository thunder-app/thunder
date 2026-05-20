import 'package:thunder/src/foundation/primitives/models/thunder_user.dart';

/// Cross-platform representation of a Lemmy or PieFed private message.
class ThunderPrivateMessage {
  /// The private message's ID.
  final int id;

  /// The message creator's user ID.
  final int? creatorId;

  /// The message recipient's user ID.
  final int? recipientId;

  /// The conversation ID for platforms that expose one.
  final int? conversationId;

  /// The private message's content.
  final String content;

  /// The private message's deleted status.
  final bool deleted;

  /// The private message's read status.
  final bool read;

  /// The private message's published date.
  final DateTime published;

  /// The private message's recipient.
  final ThunderUser? recipient;

  /// The private message's creator.
  final ThunderUser? creator;

  /// Creates a private-message model.
  ThunderPrivateMessage({
    required this.id,
    this.creatorId,
    this.recipientId,
    this.conversationId,
    required this.content,
    required this.deleted,
    required this.read,
    required this.published,
    this.recipient,
    this.creator,
  });

  /// Creates a copy with updated fields.
  ThunderPrivateMessage copyWith({
    int? id,
    int? creatorId,
    int? recipientId,
    int? conversationId,
    String? content,
    bool? deleted,
    bool? read,
    DateTime? published,
    ThunderUser? recipient,
    ThunderUser? creator,
  }) {
    return ThunderPrivateMessage(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      recipientId: recipientId ?? this.recipientId,
      conversationId: conversationId ?? this.conversationId,
      content: content ?? this.content,
      deleted: deleted ?? this.deleted,
      read: read ?? this.read,
      published: published ?? this.published,
      recipient: recipient ?? this.recipient,
      creator: creator ?? this.creator,
    );
  }

  /// Parses a Lemmy private-message payload without associated user data.
  factory ThunderPrivateMessage.fromLemmyPrivateMessage(Map<String, dynamic> privateMessage) {
    return ThunderPrivateMessage(
      id: privateMessage['id'],
      creatorId: privateMessage['creator_id'],
      recipientId: privateMessage['recipient_id'],
      content: privateMessage['content'],
      deleted: privateMessage['deleted'],
      read: privateMessage['read'],
      published: DateTime.parse(privateMessage['published']),
    );
  }

  /// Parses a Lemmy private-message view with creator and recipient data.
  factory ThunderPrivateMessage.fromLemmyPrivateMessageView(Map<String, dynamic> privateMessageView) {
    final privateMessage = privateMessageView['private_message'];
    final recipient = privateMessageView['recipient'];
    final creator = privateMessageView['creator'];

    return ThunderPrivateMessage(
      id: privateMessage['id'],
      creatorId: privateMessage['creator_id'],
      recipientId: privateMessage['recipient_id'],
      conversationId: privateMessageView['conversation_id'],
      content: privateMessage['content'],
      deleted: privateMessage['deleted'],
      read: privateMessage['read'],
      published: DateTime.parse(privateMessage['published']),
      recipient: recipient != null ? ThunderUser.fromLemmyUser(recipient) : null,
      creator: creator != null ? ThunderUser.fromLemmyUser(creator) : null,
    );
  }
}
