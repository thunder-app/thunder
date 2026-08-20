import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import 'package:thunder/src/core/persistence/persistence.dart';
import 'package:thunder/src/features/user/domain/models/user_label.dart';

/// Local Drift data source for user labels.
class UserLabelLocalDataSource {
  const UserLabelLocalDataSource._();

  static Future<UserLabel?> upsertUserLabel(UserLabel userLabel) async {
    try {
      // Check if the userLabel with the given username already exists
      final existingUserLabel = await (database.select(database.userLabels)..where((t) => t.username.equals(userLabel.username))).getSingleOrNull();

      if (existingUserLabel == null) {
        // Insert new userLabel if it doesn't exist
        int id = await database.into(database.userLabels).insert(UserLabelsCompanion.insert(username: userLabel.username, label: userLabel.label));
        return userLabel.copyWith(id: id.toString());
      } else {
        // Update existing userLabel if it exists
        await database.update(database.userLabels).replace(UserLabelsCompanion(id: Value(existingUserLabel.id), username: Value(userLabel.username), label: Value(userLabel.label)));
        return userLabel.copyWith(id: existingUserLabel.id.toString());
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<UserLabel?> fetchUserLabel(String username) async {
    if (username.isEmpty) return null;

    try {
      return await (database.select(database.userLabels)..where((t) => t.username.equals(username))).getSingleOrNull().then((userLabel) {
        if (userLabel == null) return null;
        return UserLabel(id: userLabel.id.toString(), username: userLabel.username, label: userLabel.label);
      });
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<void> deleteUserLabel(String username) async {
    try {
      await (database.delete(database.userLabels)..where((t) => t.username.equals(username))).go();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<List<UserLabel>> fetchAllUserLabels() async {
    try {
      final userLabelRows = await database.select(database.userLabels).get();
      return userLabelRows.map((userLabel) => UserLabel(id: userLabel.id.toString(), username: userLabel.username, label: userLabel.label)).toList();
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }
}
