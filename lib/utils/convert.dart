import 'package:thunder/core/models/models.dart' as models;

models.CommunityView? convertToCommunityView(dynamic communityView) {
  if (communityView == null) return null;

  return models.CommunityView(
    community: communityView.community,
    subscribed: communityView.subscribed,
    blocked: communityView.blocked,
    counts: communityView.counts,
    bannedFromCommunity: communityView.bannedFromCommunity,
  );
}
