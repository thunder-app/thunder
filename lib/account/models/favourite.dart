import 'package:sqflite/sqflite.dart';

import 'package:thunder/core/singletons/database.dart';

class Favorite {
  final String id;
  final int communityId;
  final String accountId;

  const Favorite({
    required this.id,
    required this.communityId,
    required this.accountId,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'communityId': communityId, 'accountId': accountId};
  }

  @override
  String toString() {
    return 'Favourite{id: $id, communityId: $communityId, accountId: $accountId}';
  }

  static Future<void> insertFavorite(Favorite favourite) async {
    Database? database = await DB.instance.database;
    if (database == null) return;

    await database.insert(
      'favorites',
      favourite.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // A method that retrieves all favourites from the database
  static Future<List<Favorite>> favorites(String accountId) async {
    try {
      Database? database = await DB.instance.database;
      if (database == null) return [];

      final List<Map<String, dynamic>> maps = await database.query('favorites', where: 'accountId = ?', whereArgs: [accountId]);

      return List.generate(maps.length, (i) {
        return Favorite(
          id: maps[i]['id'].toString(),
          communityId: maps[i]['communityId'],
          accountId: maps[i]['accountId'].toString(),
        );
      });
    } catch (e) {
      return [];
    }
  }

  static Future<Favorite?> fetchFavourite(String id) async {
    Database? database = await DB.instance.database;

    final List<Map<String, dynamic>>? maps = await database?.query('favorites', where: 'id = ?', whereArgs: [id]);
    if (maps == null || maps.isEmpty) return null;

    return Favorite(
      id: maps.first['id'],
      communityId: maps.first['communityId'],
      accountId: maps.first['accountId'],
    );
  }

  static Future<void> updateFavourite(Favorite favorite) async {
    Database? database = await DB.instance.database;
    if (database == null) return;

    await database.update('favorites', favorite.toMap(), where: 'id = ?', whereArgs: [favorite.id]);
  }

  static Future<void> deleteFavorite({String? id, int? communityId}) async {
    Database? database = await DB.instance.database;
    if (database == null) return;

    if (id != null) {
      await database.delete('favorites', where: 'id = ?', whereArgs: [id]);
      return;
    }

    if (communityId != null) {
      await database.delete('favorites', where: 'communityId = ?', whereArgs: [communityId]);
      return;
    }
  }
}
