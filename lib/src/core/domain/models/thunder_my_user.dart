import 'package:thunder/src/core/domain/models/thunder_community.dart';
import 'package:thunder/src/core/domain/models/thunder_local_user.dart';
import 'package:thunder/src/core/domain/models/thunder_user.dart';

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
}

class ThunderInstanceBlock {
  /// The instance being blocked.
  final Map<String, dynamic> instance;

  ThunderInstanceBlock({required this.instance});
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
}
