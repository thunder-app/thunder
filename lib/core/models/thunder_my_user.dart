import 'package:thunder/core/models/thunder_local_user.dart';
import 'package:thunder/user/models/thunder_user.dart';
import 'package:thunder/community/models/thunder_community.dart';

class ThunderLocalUserView {
  /// The local user data.
  final ThunderLocalUser localUser;

  /// The local user vote display mode.
  final ThunderLocalUserVoteDisplayMode localUserVoteDisplayMode;

  /// The person associated with this local user.
  final ThunderUser person;

  /// The person's aggregated counts.
  final Map<String, dynamic>? counts;

  ThunderLocalUserView({
    required this.localUser,
    required this.localUserVoteDisplayMode,
    required this.person,
    this.counts,
  });

  ThunderLocalUserView copyWith({
    ThunderLocalUser? localUser,
    ThunderLocalUserVoteDisplayMode? localUserVoteDisplayMode,
    ThunderUser? person,
    Map<String, dynamic>? counts,
  }) {
    return ThunderLocalUserView(
      localUser: localUser ?? this.localUser,
      localUserVoteDisplayMode: localUserVoteDisplayMode ?? this.localUserVoteDisplayMode,
      person: person ?? this.person,
      counts: counts ?? this.counts,
    );
  }

  factory ThunderLocalUserView.fromLemmyLocalUserView(Map<String, dynamic> localUserView) {
    return ThunderLocalUserView(
      localUser: ThunderLocalUser.fromLemmyLocalUser(localUserView['local_user']),
      localUserVoteDisplayMode: ThunderLocalUserVoteDisplayMode.fromLemmyVoteDisplayMode(localUserView['local_user_vote_display_mode']),
      person: ThunderUser.fromLemmyUser(localUserView['person']),
      counts: localUserView['counts'],
    );
  }
}

class ThunderCommunityFollow {
  /// The community being followed.
  final ThunderCommunity community;

  /// The follower.
  final ThunderUser follower;

  ThunderCommunityFollow({
    required this.community,
    required this.follower,
  });

  factory ThunderCommunityFollow.fromLemmyFollow(Map<String, dynamic> follow) {
    return ThunderCommunityFollow(
      community: ThunderCommunity.fromLemmyCommunity(follow['community']),
      follower: ThunderUser.fromLemmyUser(follow['follower']),
    );
  }
}

class ThunderCommunityModeration {
  /// The community being moderated.
  final ThunderCommunity community;

  /// The moderator.
  final ThunderUser moderator;

  ThunderCommunityModeration({
    required this.community,
    required this.moderator,
  });

  factory ThunderCommunityModeration.fromLemmyModeration(Map<String, dynamic> moderation) {
    return ThunderCommunityModeration(
      community: ThunderCommunity.fromLemmyCommunity(moderation['community']),
      moderator: ThunderUser.fromLemmyUser(moderation['moderator']),
    );
  }
}

class ThunderCommunityBlock {
  /// The person doing the blocking.
  final ThunderUser person;

  /// The community being blocked.
  final ThunderCommunity community;

  ThunderCommunityBlock({
    required this.person,
    required this.community,
  });

  factory ThunderCommunityBlock.fromLemmyBlock(Map<String, dynamic> block) {
    return ThunderCommunityBlock(
      person: ThunderUser.fromLemmyUser(block['person']),
      community: ThunderCommunity.fromLemmyCommunity(block['community']),
    );
  }
}

class ThunderInstanceBlock {
  /// The person doing the blocking.
  final ThunderUser person;

  /// The instance being blocked.
  final Map<String, dynamic> instance;

  /// The site associated with the instance.
  final Map<String, dynamic>? site;

  ThunderInstanceBlock({
    required this.person,
    required this.instance,
    this.site,
  });

  factory ThunderInstanceBlock.fromLemmyBlock(Map<String, dynamic> block) {
    return ThunderInstanceBlock(
      person: ThunderUser.fromLemmyUser(block['person']),
      instance: block['instance'],
      site: block['site'],
    );
  }
}

class ThunderPersonBlock {
  /// The person doing the blocking.
  final ThunderUser person;

  /// The target person being blocked.
  final ThunderUser target;

  ThunderPersonBlock({
    required this.person,
    required this.target,
  });

  factory ThunderPersonBlock.fromLemmyBlock(Map<String, dynamic> block) {
    return ThunderPersonBlock(
      person: ThunderUser.fromLemmyUser(block['person']),
      target: ThunderUser.fromLemmyUser(block['target']),
    );
  }
}

class ThunderMyUser {
  /// The local user view containing user settings and info.
  final ThunderLocalUserView localUserView;

  /// Communities the user follows.
  final List<ThunderCommunityFollow> follows;

  /// Communities the user moderates.
  final List<ThunderCommunityModeration> moderates;

  /// Communities the user has blocked.
  final List<ThunderCommunityBlock> communityBlocks;

  /// Instances the user has blocked.
  final List<ThunderInstanceBlock> instanceBlocks;

  /// People the user has blocked.
  final List<ThunderPersonBlock> personBlocks;

  /// Discussion languages the user has selected.
  final List<int>? discussionLanguages;

  ThunderMyUser({
    required this.localUserView,
    required this.follows,
    required this.moderates,
    required this.communityBlocks,
    required this.instanceBlocks,
    required this.personBlocks,
    this.discussionLanguages,
  });

  ThunderMyUser copyWith({
    ThunderLocalUserView? localUserView,
    List<ThunderCommunityFollow>? follows,
    List<ThunderCommunityModeration>? moderates,
    List<ThunderCommunityBlock>? communityBlocks,
    List<ThunderInstanceBlock>? instanceBlocks,
    List<ThunderPersonBlock>? personBlocks,
    List<int>? discussionLanguages,
  }) {
    return ThunderMyUser(
      localUserView: localUserView ?? this.localUserView,
      follows: follows ?? this.follows,
      moderates: moderates ?? this.moderates,
      communityBlocks: communityBlocks ?? this.communityBlocks,
      instanceBlocks: instanceBlocks ?? this.instanceBlocks,
      personBlocks: personBlocks ?? this.personBlocks,
      discussionLanguages: discussionLanguages ?? this.discussionLanguages,
    );
  }

  factory ThunderMyUser.fromLemmyMyUser(Map<String, dynamic> myUser) {
    final followsList = myUser['follows'] as List<dynamic>? ?? [];
    final moderatesList = myUser['moderates'] as List<dynamic>? ?? [];
    final communityBlocksList = myUser['community_blocks'] as List<dynamic>? ?? [];
    final instanceBlocksList = myUser['instance_blocks'] as List<dynamic>? ?? [];
    final personBlocksList = myUser['person_blocks'] as List<dynamic>? ?? [];
    final discussionLanguages = myUser['discussion_languages'] as List<dynamic>?;

    return ThunderMyUser(
      localUserView: ThunderLocalUserView.fromLemmyLocalUserView(myUser['local_user_view']),
      follows: followsList.map((f) => ThunderCommunityFollow.fromLemmyFollow(f)).toList(),
      moderates: moderatesList.map((m) => ThunderCommunityModeration.fromLemmyModeration(m)).toList(),
      communityBlocks: communityBlocksList.map((b) => ThunderCommunityBlock.fromLemmyBlock(b)).toList(),
      instanceBlocks: instanceBlocksList.map((b) => ThunderInstanceBlock.fromLemmyBlock(b)).toList(),
      personBlocks: personBlocksList.map((b) => ThunderPersonBlock.fromLemmyBlock(b)).toList(),
      discussionLanguages: discussionLanguages?.cast<int>(),
    );
  }
}
