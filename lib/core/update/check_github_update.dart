import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import 'package:thunder/core/models/version.dart';

Future<String?> getCurrentVersion({bool dropBuildNumber = false}) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;
  String build = packageInfo.buildNumber;

  // Adjusts the build value to only contain the numerical values for the alpha releases
  //
  // The build value is formatted as follows: internal build number + pre-release version string
  // For iOS, this looks like (e.g., 17.1, 189.3, etc.)
  // For Android, this looks like (e.g., 17-alpha.1, 189-alpha.3, etc.)
  if (dropBuildNumber) {
    if (build.contains('.')) {
      RegExp regex = RegExp(r'^[^.]*\.');
      build = build.replaceAll(regex, '');
    } else {
      build = '';
    }

    if (build.isNotEmpty) {
      return 'v$version-alpha.$build';
    }

    return 'v$version';
  }

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
