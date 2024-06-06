import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import 'package:thunder/core/database/database.dart';
import 'package:thunder/main.dart';
import 'package:thunder/utils/instance.dart';

class UserLabel {
  final String id;
  final String username;
  final String label;

  const UserLabel({
    required this.id,
    required this.username,
    required this.label,
  });

  UserLabel copyWith({String? id}) => UserLabel(
        id: id ?? this.id,
        username: username,
        label: label,
      );

  static Future<UserLabel?> upsertUserLabel(UserLabel userLabel) async {
    try {
      // Check if the userLabel with the given username already exists
      final existingUserLabel = await (database.select(database.userLabels)..where((t) => t.username.equals(userLabel.username))).getSingleOrNull();

      if (existingUserLabel == null) {
        // Insert new userLabel if it doesn't exist
        int id = await database.into(database.userLabels).insert(
              UserLabelsCompanion.insert(
                username: userLabel.username,
                label: userLabel.label,
              ),
            );
        return userLabel.copyWith(id: id.toString());
      } else {
        // Update existing userLabel if it exists
        await database.update(database.userLabels).replace(
              UserLabelsCompanion(
                id: Value(existingUserLabel.id),
                username: Value(userLabel.username),
                label: Value(userLabel.label),
              ),
            );
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
        return UserLabel(
          id: userLabel.id.toString(),
          username: userLabel.username,
          label: userLabel.label,
        );
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

  /// Generates a username string that can be used to uniquely identify entries in the UserLabels table
  static String usernameFromParts(String username, String actorId) {
    return '$username@${fetchInstanceNameFromUrl(actorId)}';
  }
}
