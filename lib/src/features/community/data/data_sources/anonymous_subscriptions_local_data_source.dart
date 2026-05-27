import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';

Future<List<ThunderCommunity>> getSubscriptions() async {
  List<LocalCommunity> subscribedCommunities = await AnonymousSubscriptions.getSubscribedCommunities();
  return subscribedCommunities.map((e) => e.toCommunity).toList();
}

Future<void> insertSubscriptions(Set<ThunderCommunity> communities) async {
  Set<LocalCommunity> subscriptions = communities.map((c) => LocalCommunity(id: c.id, name: c.name, title: c.title, actorId: c.actorId)).toSet();
  await AnonymousSubscriptions.insertCommunities(subscriptions);
}

extension on LocalCommunity {
  ThunderCommunity get toCommunity {
    return ThunderCommunity(
      id: id,
      name: name,
      title: title,
      published: DateTime.now(),
      actorId: actorId,
      icon: icon,
      instanceId: -1,
      visibility: 'Public',
      status: const CommunityStatus(removed: false, deleted: false, nsfw: false, local: false, hidden: false, postingRestrictedToMods: false),
      context: const CommunityContext(subscribed: SubscriptionStatus.subscribed), // Will always be subscribed
    );
  }
}
