import '../../globals.dart' as globals;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:thunder/core/models/version.dart';
import 'package:version/version.dart' as version_parser;

Future<String> getCurrentVersion({bool removeInternalBuildNumber = false}) async {
  RegExp regex = RegExp(r'(.+)\+.*');
  Match? match = regex.firstMatch(globals.currentVersion);

  // When removeInternalBuildNumber is specified, we remove the internal build number (e.g., +17, +18, etc.)
  if (removeInternalBuildNumber == true && match != null) {
    return 'v${match.group(1)}';
  }

  return 'v${globals.currentVersion}';
}

Future<Version> fetchVersion() async {
  const url = 'https://api.github.com/repos/thunder-app/thunder/releases';

  try {
    String currentVersion = await getCurrentVersion();
    version_parser.Version currentVersionParsed = version_parser.Version.parse(_trimV(currentVersion));

    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 3));

    if (response.statusCode == 200) {
      final release = json.decode(response.body);
      String latestVersion = release[0]['tag_name'];

      version_parser.Version latestVersionParsed = version_parser.Version.parse(_trimV(latestVersion));

      if (_compareVersions(currentVersionParsed, latestVersionParsed)) {
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

String _trimV(String version) {
  if (version.startsWith('v')) return version.substring(1);
  return version;
}

/// Returns true if [second] is greater than [first]
bool _compareVersions(version_parser.Version first, version_parser.Version second) {
  // Handle different builds (which are not normally part of semver sorting)
  int? firstBuild = int.tryParse(first.build);
  int? secondBuild = int.tryParse(second.build);
  if (firstBuild != null && secondBuild != null && firstBuild != secondBuild) {
    return secondBuild > firstBuild;
  }

  return second > first;
}
