import 'package:thunder/src/foundation/primitives/primitives.dart';

class CommunityDetails {
  final ThunderCommunity community;
  final ThunderSite? site;
  final List<ThunderUser> moderators;
  final List<int> discussionLanguages;

  const CommunityDetails({
    required this.community,
    required this.site,
    required this.moderators,
    required this.discussionLanguages,
  });
}
