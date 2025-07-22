import 'package:thunder/core/enums/subscription_status.dart';

class ThunderCommunity {
  /// The community's ID
  final int id;

  /// The community's name
  final String name;

  /// The community's title
  final String title;

  /// Helper method to get the title or name of the community
  String get titleOrName => title.isNotEmpty ? title : name;

  /// The community's description
  final String? description;

  /// Whether the community is removed
  final bool removed;

  /// The community's created date
  final DateTime published;

  /// The community's updated date
  final DateTime? updated;

  /// Whether the community is deleted
  final bool deleted;

  /// Whether the community is NSFW
  final bool nsfw;

  /// The community's actor ID
  final String actorId;

  /// Whether the community is local
  final bool local;

  /// The community's icon
  final String? icon;

  /// The community's banner
  final String? banner;

  /// Whether the community is hidden
  final bool hidden;

  /// Whether posting is restricted to mods
  final bool postingRestrictedToMods;

  /// The community's instance ID
  final int instanceId;

  /// The community's visibility
  final String visibility;

  /// The community's subscription status
  final SubscriptionStatus? subscribed;

  /// Whether the community is blocked
  final bool? blocked;

  /// Whether the current user is banned from the community
  final bool? bannedFromCommunity;

  /// The number of total subscribers
  final int? subscribers;

  /// The number of local subscribers
  final int? subscribersLocal;

  /// The number of posts
  final int? posts;

  /// The number of comments
  final int? comments;

  /// The number of users active in the last day
  final int? usersActiveDay;

  /// The number of users active in the last week
  final int? usersActiveWeek;

  /// The number of users active in the last month
  final int? usersActiveMonth;

  /// The number of users active in the last half year
  final int? usersActiveHalfYear;

  ThunderCommunity({
    required this.id,
    required this.name,
    required this.title,
    this.description,
    required this.removed,
    required this.published,
    this.updated,
    required this.deleted,
    required this.nsfw,
    required this.actorId,
    required this.local,
    this.icon,
    this.banner,
    required this.hidden,
    required this.postingRestrictedToMods,
    required this.instanceId,
    required this.visibility,
    this.subscribed,
    this.blocked,
    this.bannedFromCommunity,
    this.subscribers,
    this.subscribersLocal,
    this.posts,
    this.comments,
    this.usersActiveDay,
    this.usersActiveWeek,
    this.usersActiveMonth,
    this.usersActiveHalfYear,
  });

  factory ThunderCommunity.fromLemmyCommunity(Map<String, dynamic> community, {SubscriptionStatus? subscribed}) {
    return ThunderCommunity(
      id: community['id'],
      name: community['name'],
      title: community['title'],
      description: community['description'],
      removed: community['removed'],
      published: community['published'] != null ? DateTime.parse(community['published']) : DateTime.now(),
      updated: community['updated'] != null ? DateTime.parse(community['updated']) : null,
      deleted: community['deleted'],
      nsfw: community['nsfw'],
      actorId: community['actor_id'],
      local: community['local'],
      icon: community['icon'],
      banner: community['banner'],
      hidden: community['hidden'],
      postingRestrictedToMods: community['posting_restricted_to_mods'],
      instanceId: community['instance_id'],
      visibility: community['visibility'],
      subscribed: subscribed,
    );
  }

  factory ThunderCommunity.fromLemmyCommunityView(Map<String, dynamic> communityView) {
    final community = communityView['community'];
    final counts = communityView['counts'];

    return ThunderCommunity(
      id: community['id'],
      name: community['name'],
      title: community['title'],
      description: community['description'],
      removed: community['removed'],
      published: DateTime.parse(community['published']),
      updated: community['updated'] != null ? DateTime.parse(community['updated']) : null,
      deleted: community['deleted'],
      nsfw: community['nsfw'],
      actorId: community['actor_id'],
      local: community['local'],
      icon: community['icon'],
      banner: community['banner'],
      hidden: community['hidden'],
      postingRestrictedToMods: community['posting_restricted_to_mods'],
      instanceId: community['instance_id'],
      visibility: community['visibility'],
      subscribed: communityView['subscribed'] != null ? SubscriptionStatus.values.firstWhere((status) => status.name == communityView['subscribed']) : null,
      blocked: communityView['blocked'],
      bannedFromCommunity: communityView['banned_from_community'],
      subscribers: counts['subscribers'],
      subscribersLocal: counts['subscribers_local'],
      posts: counts['posts'],
      comments: counts['comments'],
      usersActiveDay: counts['users_active_day'],
      usersActiveWeek: counts['users_active_week'],
      usersActiveMonth: counts['users_active_month'],
      usersActiveHalfYear: counts['users_active_half_year'],
    );
  }

  factory ThunderCommunity.fromPiefedCommunity(Map<String, dynamic> community, {SubscriptionStatus? subscribed}) {
    return ThunderCommunity(
      id: community['id'],
      name: community['name'],
      title: community['title'],
      description: community['description'],
      removed: community['removed'],
      published: DateTime.parse(community['published']),
      updated: community['updated'] != null ? DateTime.parse(community['updated']) : null,
      deleted: community['deleted'],
      nsfw: community['nsfw'],
      actorId: community['actor_id'],
      local: community['local'],
      icon: community['icon'],
      banner: community['banner'],
      hidden: community['hidden'],
      postingRestrictedToMods: community['restricted_to_mods'],
      instanceId: community['instance_id'],
      visibility: "Public", // Not available in PieFed
      subscribed: subscribed,
      bannedFromCommunity: community['banned'],
    );
  }

  factory ThunderCommunity.fromPiefedCommunityView(Map<String, dynamic> communityView) {
    final community = communityView['community'];
    final counts = communityView['counts'];

    final subscribed = communityView['subscribed'] != null ? SubscriptionStatus.values.firstWhere((status) => status.name == communityView['subscribed']) : null;

    return ThunderCommunity(
      id: community['id'],
      name: community['name'],
      title: community['title'],
      description: community['description'],
      removed: community['removed'],
      published: DateTime.parse(community['published']),
      updated: community['updated'] != null ? DateTime.parse(community['updated']) : null,
      deleted: community['deleted'],
      nsfw: community['nsfw'],
      actorId: community['actor_id'],
      local: community['local'],
      icon: community['icon'],
      banner: community['banner'],
      hidden: community['hidden'],
      postingRestrictedToMods: community['restricted_to_mods'],
      instanceId: community['instance_id'],
      visibility: "Public", // Not available in PieFed
      subscribed: subscribed,
      blocked: communityView['blocked'],
      bannedFromCommunity: communityView['banned'],
      subscribers: counts['total_subscriptions_count'],
      subscribersLocal: counts['subscriptions_count'],
      posts: counts['post_count'],
      comments: counts['post_reply_count'],
      usersActiveDay: counts['active_daily'],
      usersActiveWeek: counts['active_weekly'],
      usersActiveMonth: counts['active_monthly'],
      usersActiveHalfYear: counts['active_6monthly'],
    );
  }
}
