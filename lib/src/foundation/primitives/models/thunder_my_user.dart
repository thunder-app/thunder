import 'package:thunder/src/foundation/primitives/models/thunder_community.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_local_user.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_user.dart';
import 'package:thunder/src/foundation/networking/mappers/primitive_mappers.dart';

class ThunderLocalUserView {
  /// The local user data.
  final ThunderLocalUser localUser;

  /// The person associated with this local user.
  final ThunderUser person;

  ThunderLocalUserView({
    required this.localUser,
    required this.person,
  });

  ThunderLocalUserView copyWith({
    ThunderLocalUser? localUser,
    ThunderUser? person,
  }) {
    return ThunderLocalUserView(
      localUser: localUser ?? this.localUser,
      person: person ?? this.person,
    );
  }

  factory ThunderLocalUserView.fromPiefedLocalUserView(Map<String, dynamic> localUserView) {
    const mapper = PiefedPrimitiveMapper();
    return ThunderLocalUserView(
      localUser: ThunderLocalUser.fromPiefedLocalUser(localUserView['local_user']),
      person: mapper.user(localUserView['person']),
    );
  }
}

class ThunderInstanceBlock {
  /// The instance being blocked.
  final Map<String, dynamic> instance;

  ThunderInstanceBlock({required this.instance});

  factory ThunderInstanceBlock.fromLemmyBlock(Map<String, dynamic> block) {
    return ThunderInstanceBlock(
      instance: block['instance'],
    );
  }

  factory ThunderInstanceBlock.fromPiefedBlock(Map<String, dynamic> block) {
    return ThunderInstanceBlock(
      instance: block['instance'],
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

  factory ThunderMyUser.fromLemmyV3MyUser(Map<String, dynamic> myUser) {
    final follows = myUser['follows'];
    final moderates = myUser['moderates'];
    final communityBlocks = myUser['community_blocks'];
    final instanceBlocks = myUser['instance_blocks'];
    final personBlocks = myUser['person_blocks'];
    final discussionLanguages = myUser['discussion_languages'];

    const mapper = LemmyV3PrimitiveMapper();

    return ThunderMyUser(
      localUserView: localUserViewFromLemmyV3(myUser['local_user_view']),
      follows: follows.map<ThunderCommunity>((cfv) => mapper.community(cfv['community'])).toList(),
      moderates: moderates.map<ThunderCommunity>((cmv) => mapper.community(cmv['community'])).toList(),
      communityBlocks: communityBlocks.map<ThunderCommunity>((cbv) => mapper.community(cbv['community'])).toList(),
      instanceBlocks: instanceBlocks.map<ThunderInstanceBlock>((ibv) => ThunderInstanceBlock.fromLemmyBlock(ibv)).toList(),
      personBlocks: personBlocks.map<ThunderUser>((pbv) => mapper.user(pbv['target'])).toList(),
      discussionLanguages: discussionLanguages?.cast<int>(),
    );
  }

  factory ThunderMyUser.fromLemmyV4MyUser(Map<String, dynamic> myUser) {
    const mapper = LemmyV4PrimitiveMapper();
    final follows = myUser['follows'] ?? const [];
    final moderates = myUser['moderates'] ?? const [];
    final communityBlocks = myUser['community_blocks'] ?? const [];
    final personBlocks = myUser['person_blocks'] ?? const [];
    final discussionLanguages = myUser['discussion_languages'];

    return ThunderMyUser(
      localUserView: localUserViewFromLemmyV4(myUser['local_user_view']),
      follows: follows.map<ThunderCommunity>((cfv) => mapper.community(cfv['community'])).toList(),
      moderates: moderates.map<ThunderCommunity>((cmv) => mapper.community(cmv['community'])).toList(),
      communityBlocks: communityBlocks.map<ThunderCommunity>((cbv) => mapper.community(cbv['community'] ?? cbv)).toList(),
      instanceBlocks: const [],
      personBlocks: personBlocks.map<ThunderUser>((pbv) => mapper.user(pbv['target'] ?? pbv['person'] ?? pbv)).toList(),
      discussionLanguages: discussionLanguages?.cast<int>(),
    );
  }

  factory ThunderMyUser.fromPiefedMyUser(Map<String, dynamic> myUser) {
    final follows = myUser['follows'];
    final moderates = myUser['moderates'];
    final communityBlocks = myUser['community_blocks'];
    final discussionLanguages = myUser['discussion_languages'];
    final instanceBlocks = myUser['instance_blocks'];
    final personBlocks = myUser['person_blocks'];
    final localUserView = myUser['local_user_view'];

    const mapper = PiefedPrimitiveMapper();

    return ThunderMyUser(
      localUserView: ThunderLocalUserView.fromPiefedLocalUserView(localUserView),
      follows: follows.map<ThunderCommunity>((f) => mapper.community(f['community'])).toList(),
      moderates: moderates.map<ThunderCommunity>((m) => mapper.community(m['community'])).toList(),
      communityBlocks: communityBlocks.map<ThunderCommunity>((b) => mapper.community(b['community'])).toList(),
      instanceBlocks: instanceBlocks.map<ThunderInstanceBlock>((b) => ThunderInstanceBlock.fromPiefedBlock(b)).toList(),
      personBlocks: personBlocks.map<ThunderUser>((b) => mapper.user(b['target'])).toList(),
      discussionLanguages: discussionLanguages?.map<int>((language) => language['id'] as int).toList(),
    );
  }
}
