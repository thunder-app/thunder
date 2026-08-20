import 'package:equatable/equatable.dart';

class ThunderUser extends Equatable {
  /// The user id on their home instance.
  final int id;

  /// Username without the instance domain.
  final String name;

  /// Optional display name chosen by the user.
  final String? displayName;

  /// Display name when present, otherwise the username.
  String get displayNameOrName => displayName ?? name;

  /// User avatar URL.
  final String? avatar;

  /// When the user was created.
  final DateTime published;

  /// When the user was last updated, when available.
  final DateTime? updated;

  /// Canonical ActivityPub URL for the user.
  final String actorId;

  /// User profile bio.
  final String? bio;

  /// User banner URL.
  final String? banner;

  /// Matrix user id linked to the account.
  final String? matrixUserId;

  /// ID of the instance that hosts the user.
  final int instanceId;

  /// What has happened to the user account itself.
  final UserStatus status;

  /// Post and comment counts for the user.
  final UserCounts counts;

  /// How the signed-in account relates to this user.
  final UserContext context;

  const ThunderUser({
    required this.id,
    required this.name,
    this.displayName,
    this.avatar,
    required this.published,
    this.updated,
    required this.actorId,
    this.bio,
    this.banner,
    this.matrixUserId,
    required this.instanceId,
    required this.status,
    this.counts = const UserCounts(),
    this.context = const UserContext(),
  });

  @override
  List<Object?> get props => [id, name, displayName, avatar, published, updated, actorId, bio, banner, matrixUserId, instanceId, status, counts, context];

  ThunderUser copyWith({
    int? id,
    String? name,
    String? displayName,
    String? avatar,
    DateTime? published,
    DateTime? updated,
    String? actorId,
    String? bio,
    String? banner,
    String? matrixUserId,
    int? instanceId,
    UserStatus? status,
    UserCounts? counts,
    UserContext? context,
  }) {
    return ThunderUser(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      published: published ?? this.published,
      updated: updated ?? this.updated,
      actorId: actorId ?? this.actorId,
      bio: bio ?? this.bio,
      banner: banner ?? this.banner,
      matrixUserId: matrixUserId ?? this.matrixUserId,
      instanceId: instanceId ?? this.instanceId,
      status: status ?? this.status,
      counts: counts ?? this.counts,
      context: context ?? this.context,
    );
  }
}

class UserStatus extends Equatable {
  /// Whether the user is banned.
  final bool banned;

  /// Whether the user is local to the current instance.
  final bool local;

  /// Whether the account was deleted.
  final bool deleted;

  /// Whether the account is marked as a bot.
  final bool botAccount;

  /// When the ban expires, when available.
  final DateTime? banExpires;

  const UserStatus({required this.banned, required this.local, required this.deleted, required this.botAccount, this.banExpires});

  @override
  List<Object?> get props => [banned, local, deleted, botAccount, banExpires];
}

class UserCounts extends Equatable {
  /// Number of posts created by the user.
  final int? posts;

  /// Number of comments created by the user.
  final int? comments;

  const UserCounts({this.posts, this.comments});

  @override
  List<Object?> get props => [posts, comments];
}

class UserContext extends Equatable {
  /// Whether the user is an instance admin.
  final bool? isAdmin;

  /// Whether the signed-in account blocked this user.
  final bool? blocked;

  /// Private note the signed-in account added to this user.
  final String? note;

  const UserContext({this.isAdmin, this.blocked, this.note});

  @override
  List<Object?> get props => [isAdmin, blocked, note];
}
