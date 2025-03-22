import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/community/models/anonymous_subscriptions.dart';
import 'package:thunder/core/models/thunder_community.dart';

Future<List<ThunderCommunity>> getSubscriptions() async {
  List<LocalCommunity> subscribedCommunities = await AnonymousSubscriptions.getSubscribedCommunities();
  return subscribedCommunities.map((e) => e.toCommunity).toList();
}

Future<void> insertSubscriptions(Set<ThunderCommunity> communities) async {
  Set<LocalCommunity> newCommunities = communities.map((e) => e.toLocalCommunity).toSet();
  await AnonymousSubscriptions.insertCommunities(newCommunities);
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
    );
  }
}

extension on ThunderCommunity {
  LocalCommunity get toLocalCommunity {
    return LocalCommunity(id: id, name: name, title: title, icon: icon, actorId: url);
  }
}
