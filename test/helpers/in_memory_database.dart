import 'package:drift/native.dart';

import 'package:thunder/src/foundation/persistence/persistence.dart';

AppDatabase createInMemoryDatabase() => AppDatabase(NativeDatabase.memory());
