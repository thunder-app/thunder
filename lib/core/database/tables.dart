import 'package:drift/drift.dart';
import 'package:thunder/core/database/type_converters.dart';

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

class UserLabels extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text()();
  TextColumn get label => text()();
}

class Drafts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get draftType => text().map(const DraftTypeConverter())();
  IntColumn get existingId => integer().nullable()();
  IntColumn get replyId => integer().nullable()();
  TextColumn get title => text().nullable()();
  TextColumn get url => text().nullable()();
  TextColumn get body => text().nullable()();
}

class CustomSortType extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sortType => text().map(const SortTypeConverter())();
  IntColumn get accountId => integer()();
  IntColumn get communityId => integer().nullable()();
  TextColumn get feedType => text().map(const ListingTypeConverter()).nullable()();
}
