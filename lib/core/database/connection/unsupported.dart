import 'package:drift/drift.dart';
import '../database.dart';

Never _unsupported() {
  throw UnsupportedError('No suitable database implementation was found on this platform.');
}

// Depending on the platform the app is compiled to, the following stubs will
// be replaced with the methods in native.dart or web.dart

AppDatabase constructDb() => throw UnimplementedError();

Future<void> validateDatabaseSchema(GeneratedDatabase database) async {
  _unsupported();
}
