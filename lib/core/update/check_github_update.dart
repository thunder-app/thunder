import 'package:thunder/utils/global_context.dart';

import '../../globals.dart' as globals;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:thunder/core/models/version.dart';
import 'package:version/version.dart' as version_parser;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

String getCurrentVersion({bool removeInternalBuildNumber = false, bool trimV = false}) {
  RegExp regex = RegExp(r'(.+)\+.*');
  Match? match = regex.firstMatch(globals.currentVersion);

  // When removeInternalBuildNumber is specified, we remove the internal build number (e.g., +17, +18, etc.)
  if (removeInternalBuildNumber && match != null) {
    return '${trimV ? '' : 'v'}${match.group(1)}';
  }

  return '${trimV ? '' : 'v'}${globals.currentVersion}';
}

String? _currentVersionChangelog;

Future<String> fetchCurrentVersionChangelog() async {
  if (_currentVersionChangelog != null) return _currentVersionChangelog!;

  const url = 'https://api.github.com/repos/thunder-app/thunder/releases';

  final String currentVersion = getCurrentVersion(removeInternalBuildNumber: true, trimV: true);

  try {
    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      var releases = json.decode(response.body);
      var thisRelease = (releases as List).firstWhere((release) => release['tag_name'] == currentVersion);
      _currentVersionChangelog = thisRelease['body'] as String;
      return _currentVersionChangelog!;
    }
  } catch (e) {
    // Ignore, we will return error message below.
  }

  return GlobalContext.context.mounted ? AppLocalizations.of(GlobalContext.context)!.unableToRetrieveChangelog(currentVersion) : '';
}

Future<Version> fetchVersion() async {
  const url = 'https://api.github.com/repos/thunder-app/thunder/releases';

  try {
    String currentVersion = getCurrentVersion();
    version_parser.Version currentVersionParsed = version_parser.Version.parse(_trimV(currentVersion));

    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final release = json.decode(response.body);
      String latestVersion = release[0]['tag_name'];
      String latestVersionUrl = release[0]['html_url'];

      version_parser.Version latestVersionParsed = version_parser.Version.parse(_trimV(latestVersion));

      if (latestVersionParsed > currentVersionParsed) {
        return Version(version: currentVersion, latestVersion: latestVersion, latestVersionUrl: latestVersionUrl, hasUpdate: true);
      } else {
        return Version(version: 'N/A', latestVersion: latestVersion, latestVersionUrl: latestVersionUrl, hasUpdate: false);
      }
    }

    return Version(version: currentVersion, latestVersion: 'N/A', hasUpdate: false);
  } catch (e) {
    return Version(version: 'N/A', latestVersion: 'N/A', hasUpdate: false);
  }
}

String _trimV(String version) {
  if (version.startsWith('v')) return version.substring(1);
  return version;
}
