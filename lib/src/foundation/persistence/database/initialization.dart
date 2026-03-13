import 'package:thunder/src/foundation/persistence/database/database.dart';

late AppDatabase database;

/// Initializes the database instance. This should be called before any database operations are performed.
void initializeDatabase() {
  database = AppDatabase();
}
