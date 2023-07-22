import 'package:lemmy_api_client/v3.dart';

import '../models/anonymous_subscriptions.dart';

Future<List<CommunitySafe>> getSubscriptions() async {
  List<Community> subscribedCommunities = await AnonymousSubscriptions.getSubscribedCommunities();
  return subscribedCommunities.map((e) => e.toCommunitySafe).toList();
}

Future<void> insertSubscriptions(Set<CommunitySafe> communities) async {
  Set<Community> newCommunities = communities.map((e) => e.toCommunity).toSet();
  await AnonymousSubscriptions.insertCommunities(newCommunities);
}

extension on Community {
  CommunitySafe get toCommunitySafe {
    return CommunitySafe(
        id: id, name: name, title: title, removed: false, published: DateTime.now(), deleted: false, nsfw: false, actorId: actorId, local: false, icon: icon, instanceHost: "lemmy.world");
  }
}

extension on CommunitySafe {
  Community get toCommunity {
    return Community(id: id, name: name, title: title, icon: icon, actorId: actorId);
  }
}
