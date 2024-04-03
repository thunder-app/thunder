import 'package:drift/drift.dart';

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().nullable()();
  TextColumn get jwt => text().nullable()();
  TextColumn get instance => text().nullable()();
  BoolColumn get anonymous => boolean().withDefault(const Constant(false))();
  IntColumn get userId => integer().nullable()();
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
  TextColumn get icon => text().nullable()();
}
