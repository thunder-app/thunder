import 'package:equatable/equatable.dart';

enum NotificationKind {
  /// Someone mentioned the signed-in account.
  mention,

  /// Someone replied to the signed-in account.
  reply,

  /// New content appeared in a subscribed place.
  subscribed,

  /// Someone sent a private message.
  privateMessage,

  /// A moderator action needs attention.
  modAction,
}

/// Inbox notification reference.
class NotificationRef extends Equatable {
  /// Notification id used when marking the item read or unread.
  final int id;

  /// Kind of notification this came from.
  final NotificationKind kind;

  /// Whether the notification has been read.
  final bool read;

  /// Time the notification was created.
  final DateTime createdAt;

  const NotificationRef({
    required this.id,
    required this.kind,
    required this.read,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, kind, read, createdAt];

  NotificationRef copyWith({int? id, NotificationKind? kind, bool? read, DateTime? createdAt}) {
    return NotificationRef(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
