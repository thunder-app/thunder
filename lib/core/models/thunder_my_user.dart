import 'package:thunder/core/models/thunder_local_user.dart';
import 'package:thunder/user/models/thunder_user.dart';
import 'package:thunder/community/models/thunder_community.dart';

class ThunderLocalUserView {
  /// The local user data.
  final ThunderLocalUser localUser;

  /// The local user vote display mode.
  final ThunderLocalUserVoteDisplayMode? localUserVoteDisplayMode;

  /// The person associated with this local user.
  final ThunderUser person;

  /// The person's aggregated counts.
  final Map<String, dynamic>? counts;

  ThunderLocalUserView({
    required this.localUser,
    this.localUserVoteDisplayMode,
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

  factory ThunderLocalUserView.fromPiefedLocalUserView(Map<String, dynamic> localUserView) {
    final user = ThunderUser.fromPiefedUser(localUserView['person']);

    return ThunderLocalUserView(
      localUser: ThunderLocalUser.fromPiefedLocalUser(localUserView['local_user'], user),
      // localUserVoteDisplayMode // Not available in PieFed
      person: user,
      counts: localUserView['counts'],
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

  factory ThunderInstanceBlock.fromPiefedBlock(Map<String, dynamic> block) {
    return ThunderInstanceBlock(
      person: ThunderUser.fromPiefedUser(block['person']),
      instance: block['instance'],
      site: block['site'],
    );
  }
}

class ThunderMyUser {
  /// The local user view containing user settings and info.
  final ThunderLocalUserView localUserView;

  /// Communities the user follows.
  final List<ThunderCommunity> follows;

  /// Communities the user moderates.
  final List<ThunderCommunity> moderates;

  /// Communities the user has blocked.
  final List<ThunderCommunity> communityBlocks;

  /// Instances the user has blocked.
  final List<ThunderInstanceBlock> instanceBlocks;

  /// People the user has blocked.
  final List<ThunderUser> personBlocks;

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
    List<ThunderCommunity>? follows,
    List<ThunderCommunity>? moderates,
    List<ThunderCommunity>? communityBlocks,
    List<ThunderInstanceBlock>? instanceBlocks,
    List<ThunderUser>? personBlocks,
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
    final follows = myUser['follows'];
    final moderates = myUser['moderates'];
    final communityBlocks = myUser['community_blocks'];
    final instanceBlocks = myUser['instance_blocks'];
    final personBlocks = myUser['person_blocks'];
    final discussionLanguages = myUser['discussion_languages'];

    return ThunderMyUser(
      localUserView: ThunderLocalUserView.fromLemmyLocalUserView(myUser['local_user_view']),
      follows: follows.map<ThunderCommunity>((cfv) => ThunderCommunity.fromLemmyCommunity(cfv['community'])).toList(),
      moderates: moderates.map<ThunderCommunity>((cmv) => ThunderCommunity.fromLemmyCommunity(cmv['community'])).toList(),
      communityBlocks: communityBlocks.map<ThunderCommunity>((cbv) => ThunderCommunity.fromLemmyCommunity(cbv['community'])).toList(),
      instanceBlocks: instanceBlocks.map<ThunderInstanceBlock>((ibv) => ThunderInstanceBlock.fromLemmyBlock(ibv)).toList(),
      personBlocks: personBlocks.map<ThunderUser>((pbv) => ThunderUser.fromLemmyUser(pbv['target'])).toList(),
      discussionLanguages: discussionLanguages?.cast<int>(),
    );
  }

  factory ThunderMyUser.fromPiefedMyUser(Map<String, dynamic> myUser) {
    final follows = myUser['follows'];
    final moderates = myUser['moderates'];
    final communityBlocks = myUser['community_blocks'];
    final instanceBlocks = myUser['instance_blocks'];
    final personBlocks = myUser['person_blocks'];
    final localUserView = myUser['local_user_view'];

    return ThunderMyUser(
      localUserView: ThunderLocalUserView.fromPiefedLocalUserView(localUserView),
      follows: follows.map<ThunderCommunity>((f) => ThunderCommunity.fromPiefedCommunity(f['community'])).toList(),
      moderates: moderates.map<ThunderCommunity>((m) => ThunderCommunity.fromPiefedCommunity(m['community'])).toList(),
      communityBlocks: communityBlocks.map<ThunderCommunity>((b) => ThunderCommunity.fromPiefedCommunity(b['community'])).toList(),
      instanceBlocks: instanceBlocks.map<ThunderInstanceBlock>((b) => ThunderInstanceBlock.fromPiefedBlock(b)).toList(),
      personBlocks: personBlocks.map<ThunderUser>((b) => ThunderUser.fromPiefedUser(b['target'])).toList(),
    );
  }
}
