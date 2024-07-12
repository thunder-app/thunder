import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:thunder/core/database/database.dart';
import 'package:thunder/main.dart';

class AnonymousInstance {
  final String id;
  final String instance;
  final int index;

  const AnonymousInstance({
    required this.id,
    required this.instance,
    required this.index,
  });

  AnonymousInstance copyWith({String? id, int? index}) => AnonymousInstance(
        id: id ?? this.id,
        instance: instance,
        index: index ?? this.index,
      );

  static Future<AnonymousInstance?> insertInstance(AnonymousInstance anonymousInstance) async {
    assert(anonymousInstance.id.isEmpty && anonymousInstance.index == -1);

    try {
      // Find the highest index in the current instances
      final int maxIndex = await (database.selectOnly(database.anonymousInstances)..addColumns([database.anonymousInstances.listIndex.max()]))
          .getSingle()
          .then((row) => row.read(database.anonymousInstances.listIndex.max()) ?? 0);

      // Assign the next index
      final newIndex = maxIndex + 1;

      int id = await database.into(database.anonymousInstances).insert(
            AnonymousInstancesCompanion.insert(
              instance: anonymousInstance.instance,
              listIndex: newIndex,
            ),
          );

      return anonymousInstance.copyWith(id: id.toString(), index: newIndex);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<List<AnonymousInstance>> fetchAllInstances() async {
    try {
      return (await database.select(database.anonymousInstances).get())
          .map((instance) => AnonymousInstance(
                id: instance.id.toString(),
                instance: instance.instance,
                index: instance.listIndex,
              ))
          .toList();
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  static Future<void> updateInstance(AnonymousInstance instance) async {
    try {
      await database.update(database.anonymousInstances).replace(AnonymousInstancesCompanion(
            id: Value(int.parse(instance.id)),
            instance: Value(instance.instance),
            listIndex: Value(instance.index),
          ));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<void> removeByInstanceName(String instanceName) async {
    try {
      await (database.delete(database.anonymousInstances)..where((t) => t.instance.equals(instanceName))).go();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
