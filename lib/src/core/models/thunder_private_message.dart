import 'package:thunder/src/features/user/user.dart';

class ThunderPrivateMessage {
  /// The private message's ID.
  final int id;

  /// The private message's creator ID.
  final int creatorId;

  /// The private message's recipient ID.
  final int recipientId;

  /// The private message's content.
  final String content;

  /// The private message's deleted status.
  final bool deleted;

  /// The private message's read status.
  final bool read;

  /// The private message's published date.
  final DateTime published;

  /// The private message's updated date.
  final DateTime? updated;

  /// The private message's AP ID.
  final String apId;

  /// The private message's local status.
  final bool local;

  /// The private message's recipient.
  final ThunderUser? recipient;

  /// The private message's creator.
  final ThunderUser? creator;

  ThunderPrivateMessage({
    required this.id,
    required this.creatorId,
    required this.recipientId,
    required this.content,
    required this.deleted,
    required this.read,
    required this.published,
    this.updated,
    required this.apId,
    required this.local,
    this.recipient,
    this.creator,
  });

  ThunderPrivateMessage copyWith({
    int? id,
    int? creatorId,
    int? recipientId,
    String? content,
    bool? deleted,
    bool? read,
    DateTime? published,
    DateTime? updated,
    String? apId,
    bool? local,
    ThunderUser? recipient,
    ThunderUser? creator,
  }) {
    return ThunderPrivateMessage(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      recipientId: recipientId ?? this.recipientId,
      content: content ?? this.content,
      deleted: deleted ?? this.deleted,
      read: read ?? this.read,
      published: published ?? this.published,
      updated: updated ?? this.updated,
      apId: apId ?? this.apId,
      local: local ?? this.local,
      recipient: recipient ?? this.recipient,
      creator: creator ?? this.creator,
    );
  }

  factory ThunderPrivateMessage.fromLemmyPrivateMessage(Map<String, dynamic> privateMessage) {
    return ThunderPrivateMessage(
      id: privateMessage['id'],
      creatorId: privateMessage['creator_id'],
      recipientId: privateMessage['recipient_id'],
      content: privateMessage['content'],
      deleted: privateMessage['deleted'],
      read: privateMessage['read'],
      published: DateTime.parse(privateMessage['published']),
      updated: privateMessage['updated'] != null ? DateTime.parse(privateMessage['updated']) : null,
      apId: privateMessage['ap_id'],
      local: privateMessage['local'],
    );
  }

  factory ThunderPrivateMessage.fromLemmyPrivateMessageView(Map<String, dynamic> privateMessageView) {
    final privateMessage = privateMessageView['private_message'];
    final recipient = privateMessageView['recipient'];
    final creator = privateMessageView['creator'];

    return ThunderPrivateMessage(
      id: privateMessage['id'],
      creatorId: privateMessage['creator_id'],
      recipientId: privateMessage['recipient_id'],
      content: privateMessage['content'],
      deleted: privateMessage['deleted'],
      read: privateMessage['read'],
      published: DateTime.parse(privateMessage['published']),
      updated: privateMessage['updated'] != null ? DateTime.parse(privateMessage['updated']) : null,
      apId: privateMessage['ap_id'],
      local: privateMessage['local'],
      recipient: recipient != null ? ThunderUser.fromLemmyUser(recipient) : null,
      creator: creator != null ? ThunderUser.fromLemmyUser(creator) : null,
    );
  }
}
