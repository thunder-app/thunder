import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:thunder/src/core/persistence/database/database.dart';

/// Exports the database to a file.
Future<String?> exportDatabase() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File(join(directory.path, 'thunder.sqlite'));

  return await FlutterFileDialog.saveFile(
    params: SaveFileDialogParams(mimeTypesFilter: ['application/octet-stream'], sourceFilePath: file.path, fileName: 'thunder.sqlite'),
  );
}

/// Imports the database from a file.
Future<bool> importDatabase() async {
  final path = await FlutterFileDialog.pickFile(params: const OpenFileDialogParams(fileExtensionsFilter: ['sqlite']));

  if (path != null) {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(join(directory.path, 'thunder.sqlite'));

    try {
      // Read the selected db file
      final bytes = await File(path).readAsBytes();

      // Write the file out the location we read it from
      await file.writeAsBytes(bytes, flush: true);

      // Since the db calls go straight to the file, we don't need to reload anything
      return true;
    } catch (e) {
      debugPrint('Error importing sqlite db: $e');
    }
  } else {
    debugPrint('Database import operation cancelled by user.');
  }

  return false;
}

/// Performs integrity checks on the database to ensure it is in a consistent state.
Future<void> performDatabaseIntegrityChecks(AppDatabase appDatabase) async {
  await appDatabase.customStatement("UPDATE accounts SET platform = 'lemmy' WHERE platform IS NULL");
}
