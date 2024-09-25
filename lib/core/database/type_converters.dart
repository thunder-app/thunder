import 'package:drift/drift.dart';
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
