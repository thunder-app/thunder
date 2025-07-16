class ThunderUser {
  /// The user's ID
  final int id;

  /// The user's name
  final String name;

  /// The user's display name
  final String? displayName;

  /// The user's display name or name
  String get displayNameOrName => displayName ?? name;

  /// The user's avatar
  final String? avatar;

  /// Whether the user is banned
  final bool banned;

  /// The user's created date
  final DateTime published;

  /// The user's updated date
  final DateTime? updated;

  /// The user's actor ID
  final String actorId;

  /// The user's bio
  final String? bio;

  /// Whether the user is local
  final bool local;

  /// The user's banner
  final String? banner;

  /// Whether the user is deleted
  final bool deleted;

  /// The user's matrix user ID
  final String? matrixUserId;

  /// Whether the user is a bot
  final bool botAccount;

  /// The date and time that the user's ban expires
  final DateTime? banExpires;

  /// The user's instance ID
  final int instanceId;

  /// The total number of posts that the user has made.
  final int? posts;

  /// The total number of comments that the user has made.
  final int? comments;

  /// Whether the user is an admin.
  final bool? isAdmin;

  ThunderUser({
    required this.id,
    required this.name,
    this.displayName,
    this.avatar,
    required this.banned,
    required this.published,
    this.updated,
    required this.actorId,
    this.bio,
    required this.local,
    this.banner,
    required this.deleted,
    this.matrixUserId,
    required this.botAccount,
    this.banExpires,
    required this.instanceId,
    this.posts,
    this.comments,
    this.isAdmin,
  });

  factory ThunderUser.fromLemmyUser(Map<String, dynamic> user) {
    return ThunderUser(
      id: user['id'],
      name: user['name'],
      displayName: user['display_name'],
      avatar: user['avatar'],
      banned: user['banned'],
      published: DateTime.parse(user['published']),
      updated: user['updated'] != null ? DateTime.parse(user['updated']) : null,
      actorId: user['actor_id'],
      bio: user['bio'],
      local: user['local'],
      banner: user['banner'],
      deleted: user['deleted'],
      matrixUserId: user['matrix_user_id'],
      botAccount: user['bot_account'],
      banExpires: user['ban_expires'] != null ? DateTime.parse(user['ban_expires']) : null,
      instanceId: user['instance_id'],
    );
  }

  factory ThunderUser.fromLemmyUserView(Map<String, dynamic> userView) {
    final user = userView['person'];
    final counts = userView['counts'];

    return ThunderUser(
      id: user['id'],
      name: user['name'],
      displayName: user['display_name'],
      avatar: user['avatar'],
      banned: user['banned'],
      published: DateTime.parse(user['published']),
      updated: user['updated'] != null ? DateTime.parse(user['updated']) : null,
      actorId: user['actor_id'],
      bio: user['bio'],
      local: user['local'],
      banner: user['banner'],
      deleted: user['deleted'],
      matrixUserId: user['matrix_user_id'],
      botAccount: user['bot_account'],
      banExpires: user['ban_expires'] != null ? DateTime.parse(user['ban_expires']) : null,
      instanceId: user['instance_id'],
      posts: counts['post_count'],
      comments: counts['comment_count'],
      isAdmin: userView['is_admin'],
    );
  }
}
