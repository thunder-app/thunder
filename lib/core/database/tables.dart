import 'package:drift/drift.dart';

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text()();
  TextColumn get jwt => text()();
  TextColumn get instance => text()();
  BoolColumn get anonymous => boolean().withDefault(const Constant(false))();
  IntColumn get userId => integer().withDefault(const Constant(-1))();
}

class Favorites extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accountId => integer()();
  IntColumn get communityId => integer()();
}

class LocalSubscriptions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get title => text()();
  TextColumn get actorId => text()();
  TextColumn get icon => text()();
}
