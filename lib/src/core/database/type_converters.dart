import 'package:drift/drift.dart';

import 'package:thunder/src/core/enums/threadiverse_platform.dart';
import 'package:thunder/src/features/drafts/drafts.dart';

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

class ThreadiversePlatformConverter extends TypeConverter<ThreadiversePlatform?, String?> {
  const ThreadiversePlatformConverter();

  @override
  ThreadiversePlatform? fromSql(String? fromDb) {
    return ThreadiversePlatform.fromString(fromDb);
  }

  @override
  String? toSql(ThreadiversePlatform? value) {
    return value?.toStringValue();
  }
}
