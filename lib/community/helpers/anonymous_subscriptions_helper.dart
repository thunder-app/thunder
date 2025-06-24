import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/community/models/anonymous_subscriptions.dart';
import 'package:thunder/core/models/thunder_community.dart';

Future<List<ThunderCommunity>> getSubscriptions() async {
  List<LocalCommunity> subscribedCommunities = await AnonymousSubscriptions.getSubscribedCommunities();
  return subscribedCommunities.map((e) => e.toCommunity).toList();
}

Future<void> insertSubscriptions(Set<ThunderCommunity> communities) async {
  Set<LocalCommunity> subscriptions = communities.map((c) => LocalCommunity(id: c.id, name: c.name, title: c.title, actorId: c.url)).toSet();
  await AnonymousSubscriptions.insertCommunities(subscriptions);
}

extension on LocalCommunity {
  ThunderCommunity get toCommunity {
    return ThunderCommunity(
      Community(
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
      ),
      subscribed: SubscribedType.subscribed, // Will always be subscribed
    );
  }
}
