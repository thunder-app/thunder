import 'package:equatable/equatable.dart';

import 'package:thunder/src/foundation/primitives/enums/subscription_status.dart';

class ThunderCommunity extends Equatable {
  /// The community id on its home instance.
  final int id;

  /// Community handle without the instance domain.
  final String name;

  /// Display title for the community.
  final String title;

  /// Display title when present, otherwise the community handle.
  String get titleOrName => title.isNotEmpty ? title : name;

  /// Sidebar or description text.
  final String? description;

  /// When the community was created.
  final DateTime published;

  /// When the community was last updated, when available.
  final DateTime? updated;

  /// Canonical ActivityPub URL for the community.
  final String actorId;

  /// Community icon URL.
  final String? icon;

  /// Community banner URL.
  final String? banner;

  /// ID of the instance that hosts it.
  final int instanceId;

  /// Visibility label used by the community's platform.
  final String visibility;

  /// What has happened to the community itself.
  final CommunityStatus status;

  /// Subscriber, post, comment, and activity counts.
  final CommunityCounts counts;

  /// How the signed-in account relates to this community.
  final CommunityContext context;

  const ThunderCommunity({
    required this.id,
    required this.name,
    required this.title,
    this.description,
    required this.published,
    this.updated,
    required this.actorId,
    this.icon,
    this.banner,
    required this.instanceId,
    required this.visibility,
    required this.status,
    this.counts = const CommunityCounts(),
    this.context = const CommunityContext(),
  });

  @override
  List<Object?> get props => [
        id,
        name,
        title,
        description,
        published,
        updated,
        actorId,
        icon,
        banner,
        instanceId,
        visibility,
        status,
        counts,
        context,
      ];

  ThunderCommunity copyWith({
    int? id,
    String? name,
    String? title,
    String? description,
    DateTime? published,
    DateTime? updated,
    String? actorId,
    String? icon,
    String? banner,
    int? instanceId,
    String? visibility,
    CommunityStatus? status,
    CommunityCounts? counts,
    CommunityContext? context,
  }) {
    return ThunderCommunity(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      description: description ?? this.description,
      published: published ?? this.published,
      updated: updated ?? this.updated,
      actorId: actorId ?? this.actorId,
      icon: icon ?? this.icon,
      banner: banner ?? this.banner,
      instanceId: instanceId ?? this.instanceId,
      visibility: visibility ?? this.visibility,
      status: status ?? this.status,
      counts: counts ?? this.counts,
      context: context ?? this.context,
    );
  }
}

class CommunityStatus extends Equatable {
  /// Whether moderators removed it.
  final bool removed;

  /// Whether it was deleted.
  final bool deleted;

  /// Whether it is marked not safe for work.
  final bool nsfw;

  /// Whether it is local to the current instance.
  final bool local;

  /// Whether it is hidden from listings.
  final bool hidden;

  /// Whether only moderators can create posts.
  final bool postingRestrictedToMods;

  const CommunityStatus({
    required this.removed,
    required this.deleted,
    required this.nsfw,
    required this.local,
    required this.hidden,
    required this.postingRestrictedToMods,
  });

  @override
  List<Object?> get props => [removed, deleted, nsfw, local, hidden, postingRestrictedToMods];
}

class CommunityCounts extends Equatable {
  /// Total subscribers known by the instance.
  final int? subscribers;

  /// Subscribers local to the community's home instance.
  final int? subscribersLocal;

  /// Number of posts in the community.
  final int? posts;

  /// Number of comments in the community.
  final int? comments;

  /// Active users in the last day.
  final int? usersActiveDay;

  /// Active users in the last week.
  final int? usersActiveWeek;

  /// Active users in the last month.
  final int? usersActiveMonth;

  /// Active users in the last half year.
  final int? usersActiveHalfYear;

  const CommunityCounts({
    this.subscribers,
    this.subscribersLocal,
    this.posts,
    this.comments,
    this.usersActiveDay,
    this.usersActiveWeek,
    this.usersActiveMonth,
    this.usersActiveHalfYear,
  });

  @override
  List<Object?> get props => [subscribers, subscribersLocal, posts, comments, usersActiveDay, usersActiveWeek, usersActiveMonth, usersActiveHalfYear];
}

class CommunityContext extends Equatable {
  /// Subscription state for the signed-in account.
  final SubscriptionStatus? subscribed;

  /// Whether the signed-in account blocked it.
  final bool? blocked;

  /// Whether the signed-in account is banned from it.
  final bool? bannedFromCommunity;

  /// Whether the signed-in account can moderate it.
  final bool? canModerate;

  const CommunityContext({this.subscribed, this.blocked, this.bannedFromCommunity, this.canModerate});

  @override
  List<Object?> get props => [subscribed, blocked, bannedFromCommunity, canModerate];
}
