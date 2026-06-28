import 'package:equatable/equatable.dart';

import 'package:thunder/src/foundation/primitives/primitives.dart';

class CommunityDetail extends Equatable {
  /// The community information
  final ThunderCommunity community;

  /// The site information, if available
  final ThunderSite? site;

  /// The list of moderators for the community
  final List<ThunderUser> moderators;

  /// The list of discussion languages available for the community
  final List<int> discussionLanguages;

  /// The list of flairs available for the community. PieFed only.
  final List<ThunderFlair> flairs;

  const CommunityDetail({
    required this.community,
    required this.site,
    required this.moderators,
    required this.discussionLanguages,
    this.flairs = const [],
  });

  @override
  List<Object?> get props => [community, site, moderators, discussionLanguages, flairs];
}
