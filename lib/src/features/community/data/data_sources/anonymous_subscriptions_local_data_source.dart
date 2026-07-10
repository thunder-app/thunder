import 'package:flutter/foundation.dart';

import 'package:drift/drift.dart';

import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/persistence/persistence.dart';
import 'package:thunder/src/features/community/domain/models/local_community.dart';

/// Local Drift data source for anonymous community subscriptions.
class AnonymousSubscriptionsLocalDataSource {
  const AnonymousSubscriptionsLocalDataSource._();

  static Future<void> insertCommunities(Set<LocalCommunity> communities) async {
    try {
      for (LocalCommunity community in communities) {
        await database
            .into(database.localSubscriptions)
            .insert(LocalSubscriptionsCompanion.insert(name: community.name, title: community.title, actorId: community.actorId, icon: Value(community.icon)));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<void> deleteCommunities(Set<String> urls) async {
    try {
      await (database.delete(database.localSubscriptions)..where((t) => t.actorId.isIn(urls))).go();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<List<LocalCommunity>> getSubscribedCommunities() async {
    try {
      return (await database.localSubscriptions.all().get())
          .map((community) => LocalCommunity(id: community.id, name: community.name, title: community.title, actorId: community.actorId, icon: community.icon))
          .toList();
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  static Future<List<ThunderCommunity>> getSubscriptions() async {
    final subscribedCommunities = await getSubscribedCommunities();
    return subscribedCommunities.map(_toCommunity).toList();
  }

  static Future<void> insertSubscriptions(Set<ThunderCommunity> communities) async {
    final subscriptions = communities.map((c) => LocalCommunity(id: c.id, name: c.name, title: c.title, actorId: c.actorId)).toSet();
    await insertCommunities(subscriptions);
  }

  static ThunderCommunity _toCommunity(LocalCommunity community) {
    return ThunderCommunity(
      id: community.id,
      name: community.name,
      title: community.title,
      published: DateTime.now(),
      actorId: community.actorId,
      icon: community.icon,
      instanceId: -1,
      visibility: 'Public',
      status: const CommunityStatus(removed: false, deleted: false, nsfw: false, local: false, hidden: false, postingRestrictedToMods: false),
      context: const CommunityContext(subscribed: SubscriptionStatus.subscribed),
    );
  }
}
