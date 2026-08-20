import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:thunder/src/core/domain/enums/local_settings.dart';
import 'package:thunder/src/core/persistence/preferences_migration.dart';

const internalPreferencesPrefix = '__thunder_internal_';

/// A singleton class to manage user preferences using SharedPreferences.
///
/// This class provides methods to fetch, update, export, and import user settings.
class UserPreferences {
  /// The instance of SharedPreferences used internally.
  late SharedPreferences preferences;

  // Private constructor that can only be used within this class
  UserPreferences._();

  // Single instance of the class
  static final UserPreferences _instance = UserPreferences._();

  // Public getter to access the singleton instance
  static UserPreferences get instance => _instance;

  // Initialize the SharedPreferences instance
  Future<void> initialize() async {
    preferences = await SharedPreferences.getInstance();
  }

  /// Returns the file path for the JSON file used for exporting preferences.
  static Future<String> _getJsonFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/thunder_prefs.json';
  }

  /// Exports SharedPreferences data to a JSON file and filters out settings that are excluded from import/export.
  ///
  /// Returns the file path of the exported JSON file or null if the operation is canceled.
  /// Throws exceptions if file operations fail.
  static Future<String?> exportToJson() async {
    try {
      String jsonData = json.encode(exportableValues());
      String filePath = await _getJsonFilePath();

      final file = File(filePath);
      await file.writeAsString(jsonData);

      return await FlutterFileDialog.saveFile(
        params: SaveFileDialogParams(mimeTypesFilter: ['application/json'], sourceFilePath: filePath, fileName: 'thunder_prefs.json'),
      );
    } catch (e) {
      debugPrint('Error exporting preferences: $e');
      return null;
    }
  }

  /// Imports JSON data from a selected file into SharedPreferences.
  ///
  /// Returns true if the import is successful, false otherwise.
  static Future<bool> importFromJson() async {
    try {
      final filePath = await FlutterFileDialog.pickFile(params: const OpenFileDialogParams(fileExtensionsFilter: ['json']));

      if (filePath != null) {
        final file = File(filePath);
        String jsonData = await file.readAsString();
        Map<String, dynamic> data = json.decode(jsonData);

        await applyImportedValues(data);

        return true;
      } else {
        debugPrint("Import operation cancelled by user.");
      }
    } catch (e) {
      debugPrint('Error importing preferences: $e');
    }
    return false;
  }

  /// Returns the user-facing preference values that are safe to export.
  static Map<String, dynamic> exportableValues() {
    final prefs = instance.preferences;
    return prefs.getKeys().where((key) => !key.startsWith(internalPreferencesPrefix) && !LocalSettings.importExportExcludedSettings.any((excluded) => key.startsWith(excluded.name))).fold({}, (
      values,
      key,
    ) {
      values[key] = prefs.get(key);
      return values;
    });
  }

  /// Applies imported user-facing values, then reruns migrations before callers reload settings.
  static Future<void> applyImportedValues(Map<String, dynamic> data) async {
    final prefs = instance.preferences;
    for (final entry in data.entries) {
      if (entry.key.startsWith(internalPreferencesPrefix)) continue;
      await setValue(prefs, entry.key, entry.value);
    }

    await prefs.remove(sharedPreferencesMigrationVersionKey);
    await performSharedPreferencesMigration();
  }

  /// Helper method to set a value in SharedPreferences based on its type
  static Future<bool> setValue(SharedPreferences prefs, String key, dynamic value) async {
    if (value is int) {
      return prefs.setInt(key, value);
    } else if (value is double) {
      return prefs.setDouble(key, value);
    } else if (value is bool) {
      return prefs.setBool(key, value);
    } else if (value is String) {
      return prefs.setString(key, value);
    } else if (value is List) {
      return prefs.setStringList(key, value.map((e) => e.toString()).toList());
    }

    return false;
  }

  /// Fetches the value of a specific LocalSetting.
  ///
  /// Returns the value of the setting or null if not found.
  /// Type parameter T should match the expected type of the setting.
  static T? getLocalSetting<T>(LocalSettings setting) {
    final prefs = instance.preferences;
    final value = prefs.get(setting.name);

    if (value != null && value is T) {
      return value as T;
    }

    return null;
  }

  /// Updates or sets the value of a specific LocalSetting.
  ///
  /// Throws an [ArgumentError] if the value type is unsupported.
  static Future<void> setSetting<T>(LocalSettings setting, T value) async {
    final prefs = instance.preferences;

    if (value is int) {
      await prefs.setInt(setting.name, value);
    } else if (value is double) {
      await prefs.setDouble(setting.name, value);
    } else if (value is bool) {
      await prefs.setBool(setting.name, value);
    } else if (value is String) {
      await prefs.setString(setting.name, value);
    } else if (value is List<String>) {
      await prefs.setStringList(setting.name, value);
    } else {
      throw ArgumentError('Unsupported value type: ${value.runtimeType}');
    }
  }

  /// Removes a specific LocalSetting.
  ///
  /// Returns true if the setting was successfully removed, false otherwise.
  static Future<bool> removeSetting(LocalSettings setting) async {
    final prefs = instance.preferences;
    return await prefs.remove(setting.name);
  }

  /// Clears all preferences.
  ///
  /// Returns true if preferences were successfully cleared, false otherwise.
  static Future<bool> clearAllPreferences() async {
    final prefs = instance.preferences;
    return await prefs.clear();
  }
}
