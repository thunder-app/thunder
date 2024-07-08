import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thunder/core/enums/local_settings.dart';

class UserPreferences {
  late SharedPreferences sharedPreferences;

  static Future<UserPreferences> fetchPreferences() async {
    _preferences ??= UserPreferences()..sharedPreferences = await SharedPreferences.getInstance();
    return _preferences!;
  }

  static UserPreferences? _preferences;

  static Future<UserPreferences> get instance => fetchPreferences();

  static Future<String> _getJsonFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/thunder_prefs.json';
  }

  // Export SharedPreferences data to selected JSON file
  static Future<String?> exportToJson() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> data = prefs.getKeys().where((key) => !LocalSettings.importExportExcludedSettings.any((excluded) => key.startsWith(excluded.name))).fold({}, (prev, key) {
      prev[key] = prefs.get(key);
      return prev;
    });

    String jsonData = json.encode(data);
    String filePath = await _getJsonFilePath();

    final file = File(filePath);
    await file.writeAsString(jsonData);

    return await FlutterFileDialog.saveFile(
      params: SaveFileDialogParams(
        mimeTypesFilter: ['application/json'],
        sourceFilePath: filePath,
        fileName: 'thunder_prefs.json',
      ),
    );
  }

  // Import JSON data from selected file to SharedPreferences
  static Future<bool> importFromJson() async {
    final filePath = await FlutterFileDialog.pickFile(
      params: const OpenFileDialogParams(
        fileExtensionsFilter: ['json'],
      ),
    );

    if (filePath != null) {
      final file = File(filePath);
      String jsonData = await file.readAsString();
      Map<String, dynamic> data = json.decode(jsonData);

      SharedPreferences prefs = await SharedPreferences.getInstance();

      data.forEach((key, value) {
        if (value is int) {
          prefs.setInt(key, value);
        } else if (value is double) {
          prefs.setDouble(key, value);
        } else if (value is bool) {
          prefs.setBool(key, value);
        } else if (value is String) {
          prefs.setString(key, value);
        }
      });

      return true;
    } else {
      debugPrint("Import operation cancelled by user.");
    }

    return false;
  }
}
