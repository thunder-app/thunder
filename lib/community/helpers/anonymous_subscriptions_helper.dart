import 'package:thunder/community/models/anonymous_subscriptions.dart';
import 'package:thunder/core/enums/subscription_status.dart';
import 'package:thunder/community/models/thunder_community.dart';

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
      removed: false,
      published: DateTime.now(),
      deleted: false,
      nsfw: false,
      actorId: actorId,
      local: false,
      icon: icon,
      hidden: false,
      postingRestrictedToMods: false,
      instanceId: -1,
      visibility: 'Public',
      subscribed: SubscriptionStatus.subscribed, // Will always be subscribed
    );
  }
}
