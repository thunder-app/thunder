import 'package:thunder/core/enums/enums.dart';
import 'package:thunder/core/models/models.dart';

CommunityView? convertToCommunityView(dynamic communityView) {
  if (communityView == null) return null;

  return CommunityView(
    community: convertToCommunity(communityView.community)!,
    subscribed: communityView.subscribed,
    blocked: communityView.blocked,
    counts: communityView.counts,
    bannedFromCommunity: communityView.bannedFromCommunity,
  );
}

Community? convertToCommunity(dynamic community) {
  if (community == null) return null;

  return Community(
    id: community.id,
    name: community.name,
    title: community.title,
    description: community.description,
    removed: community.removed,
    published: community.published,
    updated: community.updated,
    deleted: community.deleted,
    nsfw: community.nsfw,
    actorId: community.actorId,
    local: community.local,
    icon: community.icon,
    banner: community.banner,
    hidden: community.hidden,
    postingRestrictedToMods: community.postingRestrictedToMods,
    instanceId: community.instanceId,
    visibility: community.visibility,
  );
}

SubscribedType? convertToSubscribedType(dynamic subscribedType) {
  if (subscribedType == null) return null;

  return SubscribedType.values.firstWhere((e) => e.name == subscribedType.name);
}
