import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import 'package:thunder/core/database/database.dart';
import 'package:thunder/main.dart';

class Favorite {
  final String id;
  final int communityId;
  final String accountId;

  const Favorite({
    required this.id,
    required this.communityId,
    required this.accountId,
  });

  Favorite copyWith({String? id}) => Favorite(
        id: id ?? this.id,
        communityId: communityId,
        accountId: accountId,
      );

  static Future<Favorite?> insertFavorite(Favorite favourite) async {
    // If we are given a brand new favorite to insert with an existing id, something is wrong.
    assert(favourite.id.isEmpty);

    try {
      int id = await database.into(database.favorites).insert(FavoritesCompanion.insert(
            accountId: int.parse(favourite.accountId),
            communityId: favourite.communityId,
          ));
      return favourite.copyWith(id: id.toString());
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  // A method that retrieves all favourites from the database
  static Future<List<Favorite>> favorites(String accountId) async {
    try {
      return (await database.favorites.all().get()).map((favorite) => Favorite(id: favorite.id.toString(), accountId: favorite.accountId.toString(), communityId: favorite.communityId)).toList();
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  static Future<Favorite?> fetchFavourite(String id) async {
    try {
      return await (database.select(database.favorites)..where((t) => t.id.equals(int.parse(id)))).getSingleOrNull().then((favorite) {
        if (favorite == null) return null;
        return Favorite(id: favorite.id.toString(), accountId: favorite.accountId.toString(), communityId: favorite.communityId);
      });
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<void> updateFavourite(Favorite favorite) async {
    try {
      await database.update(database.favorites).replace(FavoritesCompanion(
            id: Value(int.parse(favorite.id)),
            accountId: Value(int.parse(favorite.accountId)),
            communityId: Value(favorite.communityId),
          ));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<void> deleteFavorite({String? id, int? communityId}) async {
    try {
      if (id != null) {
        await (database.delete(database.favorites)..where((t) => t.id.equals(int.parse(id)))).go();
        return;
      }

      if (communityId != null) {
        await (database.delete(database.favorites)..where((t) => t.communityId.equals(communityId))).go();
        return;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
