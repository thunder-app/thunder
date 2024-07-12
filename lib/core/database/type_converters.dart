import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/drafts/draft_type.dart';

class DraftTypeConverter extends TypeConverter<DraftType, String> {
  const DraftTypeConverter();

  @override
  DraftType fromSql(String fromDb) {
    return DraftType.values.byName(fromDb);
  }

  @override
  String toSql(DraftType value) {
    return value.name;
  }
}

/// Converts [SortType] to be stored in the database and vice versa
class SortTypeConverter extends TypeConverter<SortType, String> {
  const SortTypeConverter();

  @override
  SortType fromSql(String fromDb) {
    return SortType.values.firstWhereOrNull((element) => element.toString() == fromDb) ?? SortType.hot;
  }

  @override
  String toSql(SortType value) {
    return value.toString();
  }
}

/// Converts [ListingType] to be stored in the database and vice versa
class ListingTypeConverter extends TypeConverter<ListingType, String> {
  const ListingTypeConverter();

  @override
  ListingType fromSql(String fromDb) {
    return ListingType.values.byName(fromDb);
  }

  @override
  String toSql(ListingType value) {
    return value.name;
  }
}
