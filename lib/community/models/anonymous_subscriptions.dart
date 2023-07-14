import 'package:lemmy_api_client/v3.dart';
import 'package:sqflite/sqflite.dart';
import 'package:thunder/core/singletons/database.dart';

class Community {
  final int id;
  final String name;
  final String title;
  final String actorId;
  final String? icon;

  const Community(
      {required this.id,
      required this.name,
      required this.title,
      required this.actorId,
      this.icon});

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
  static Future<void> insertCommunities(Set<Community> communities) async {
    Database? database = await DB.instance.database;
    if (database == null) return;

    Batch batch = database.batch();
    for (var element in communities) {
      batch.insert("anonymous_subscriptions", element.toMap());
    }
    batch.commit();
  }

  static Future<void> deleteCommunities(Set<int> ids) async {
    Database? database = await DB.instance.database;
    if (database == null) return;

    Batch batch = database.batch();
    for (var element in ids) {
      batch.delete("anonymous_subscriptions",
          where: 'id = ?', whereArgs: [element]);
    }
    batch.commit();
  }

  static Future<List<Community>> getSubscribedCommunities() async {
    Database? database = await DB.instance.database;
    if (database == null) return [];

    final List<Map<String, dynamic>> maps =
        await database.query('anonymous_subscriptions');

    return List.generate(maps.length, (i) {
      return Community(
        id: maps[i]["id"],
        name: maps[i]["name"],
        title: maps[i]["title"],
        actorId: maps[i]["actorId"],
        icon: maps[i]["icon"],
      );
    });
  }
}
