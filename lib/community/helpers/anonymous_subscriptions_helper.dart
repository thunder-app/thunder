import 'package:thunder/core/models/models.dart';

import '../models/anonymous_subscriptions.dart';

Future<List<Community>> getSubscriptions() async {
  List<LocalCommunity> subscribedCommunities = await AnonymousSubscriptions.getSubscribedCommunities();
  return subscribedCommunities.map((e) => e.toCommunity).toList();
}

Future<void> insertSubscriptions(Set<Community> communities) async {
  Set<LocalCommunity> newCommunities = communities.map((e) => e.toLocalCommunity).toSet();
  await AnonymousSubscriptions.insertCommunities(newCommunities);
}

extension on LocalCommunity {
  Community get toCommunity {
    return Community(
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
    );
  }
}

extension on Community {
  LocalCommunity get toLocalCommunity {
    return LocalCommunity(id: id, name: name, title: title, icon: icon, actorId: actorId);
  }
}
