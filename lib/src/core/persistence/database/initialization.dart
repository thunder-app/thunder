import 'package:thunder/src/core/persistence/database/database.dart';

late AppDatabase database;

/// Initializes the database instance. This should be called before any database operations are performed.
AppDatabase initializeDatabase() {
  database = AppDatabase();
  return database;
}
