import 'package:flutter/foundation.dart';

import 'package:drift/drift.dart';

import 'package:thunder/core/database/database.dart';
import 'package:thunder/main.dart';

class LocalCommunity {
  final int id;
  final String name;
  final String title;
  final String actorId;
  final String? icon;

  const LocalCommunity({required this.id, required this.name, required this.title, required this.actorId, this.icon});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "title": title,
      "actorId": actorId,
      "icon": icon,
    };
  }
}

class AnonymousSubscriptions {
  AnonymousSubscriptions();

  // To insert multiple communities to database
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
}
