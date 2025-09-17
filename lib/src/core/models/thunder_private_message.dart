import 'package:thunder/src/features/user/user.dart';

class ThunderPrivateMessage {
  /// The private message's ID.
  final int id;

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

  ThunderPrivateMessage({
    required this.id,
    required this.content,
    required this.deleted,
    required this.read,
    required this.published,
    this.recipient,
    this.creator,
  });

  ThunderPrivateMessage copyWith({
    int? id,
    String? content,
    bool? deleted,
    bool? read,
    DateTime? published,
    ThunderUser? recipient,
    ThunderUser? creator,
  }) {
    return ThunderPrivateMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      deleted: deleted ?? this.deleted,
      read: read ?? this.read,
      published: published ?? this.published,
      recipient: recipient ?? this.recipient,
      creator: creator ?? this.creator,
    );
  }

  factory ThunderPrivateMessage.fromLemmyPrivateMessage(Map<String, dynamic> privateMessage) {
    return ThunderPrivateMessage(
      id: privateMessage['id'],
      content: privateMessage['content'],
      deleted: privateMessage['deleted'],
      read: privateMessage['read'],
      published: DateTime.parse(privateMessage['published']),
    );
  }

  factory ThunderPrivateMessage.fromLemmyPrivateMessageView(Map<String, dynamic> privateMessageView) {
    final privateMessage = privateMessageView['private_message'];
    final recipient = privateMessageView['recipient'];
    final creator = privateMessageView['creator'];

    return ThunderPrivateMessage(
      id: privateMessage['id'],
      content: privateMessage['content'],
      deleted: privateMessage['deleted'],
      read: privateMessage['read'],
      published: DateTime.parse(privateMessage['published']),
      recipient: recipient != null ? ThunderUser.fromLemmyUser(recipient) : null,
      creator: creator != null ? ThunderUser.fromLemmyUser(creator) : null,
    );
  }
}
