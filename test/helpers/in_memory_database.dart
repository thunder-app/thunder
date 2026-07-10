import 'package:drift/native.dart';

import 'package:thunder/src/core/persistence/persistence.dart';

AppDatabase createInMemoryDatabase() => AppDatabase(NativeDatabase.memory());
