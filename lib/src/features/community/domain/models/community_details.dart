import 'package:thunder/src/foundation/primitives/primitives.dart';

class CommunityDetails {
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

  const CommunityDetails({
    required this.community,
    required this.site,
    required this.moderators,
    required this.discussionLanguages,
    this.flairs = const [],
  });
}
