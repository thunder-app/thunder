import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import 'package:thunder/core/models/version.dart';

Future<String?> getCurrentVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;
  String build = packageInfo.buildNumber;

  return 'v$version+$build';
}

Future<Version> fetchVersion() async {
  const url = 'https://api.github.com/repos/hjiangsu/thunder/releases/latest';

  try {
    String? currentVersion = await getCurrentVersion();

    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 3));

    if (response.statusCode == 200) {
      final release = json.decode(response.body);
      String latestVersion = release['tag_name'];

      if (currentVersion != null && currentVersion.compareTo(latestVersion) < 0) {
        return Version(version: currentVersion, latestVersion: latestVersion, hasUpdate: true);
      } else {
        return Version(version: 'N/A', latestVersion: latestVersion, hasUpdate: false);
      }
    }

    return Version(version: currentVersion ?? 'N/A', latestVersion: 'N/A', hasUpdate: false);
  } catch (e) {
    return Version(version: 'N/A', latestVersion: 'N/A', hasUpdate: false);
  }
}
