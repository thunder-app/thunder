import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/account/api.dart';
import 'package:thunder/src/features/instance/api.dart';

/// Fetches the instance info for a given URL.
///
/// This includes the instance name, version, icon, and user count.
/// If the URL is invalid or the instance is unreachable, it returns a default [ThunderInstanceInfo] with success set to false.
Future<ThunderInstanceInfo> getInstanceInfo(String? url, {int? id, Duration? timeout}) async {
  if (url?.isEmpty ?? true) {
    return ThunderInstanceInfo(
      domain: '',
      name: '',
      success: false,
    );
  }

  try {
    final platformInfo = await detectPlatformFromNodeInfo(url!);
    final platform = platformInfo?['platform'];

    final account = Account(instance: url, id: '', index: -1, platform: platform);

    final site = await InstanceRepositoryImpl(account: account).info().timeout(timeout ?? const Duration(seconds: 5));
    final instance = site.site;

    return ThunderInstanceInfo(
      id: id,
      domain: _fetchInstanceNameFromUrl(instance.actorId) ?? '',
      version: site.version,
      name: instance.name,
      icon: instance.icon,
      users: instance.users,
      success: true,
      platform: platform,
      contentWarning: site.site.contentWarning,
    );
  } catch (e) {
    debugPrint('Error getting instance info: $e');

    return ThunderInstanceInfo(
      domain: '',
      name: '',
      success: false,
    );
  }
}

/// Determines the proper ThreadiversePlatform by fetching software information from nodeinfo.
///
/// Given a URL, fetches the .well-known/nodeinfo endpoint and parses the JSON response
/// to determine the underlying software platform (lemmy, piefed, etc.).
///
/// Returns the detected ThreadiversePlatform or null if detection fails.
Future<Map<String, dynamic>?> detectPlatformFromNodeInfo(String url, {Duration? timeout}) async {
  if (url.isEmpty) return null;

  try {
    Uri uri;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      uri = Uri.parse('https://$url');
    } else {
      uri = Uri.parse(url);
    }

    final nodeInfoUri = Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.port,
      path: '/.well-known/nodeinfo',
    );

    final response = await http.get(nodeInfoUri).timeout(timeout ?? const Duration(seconds: 5));

    if (response.statusCode != 200) {
      return null;
    }

    final Map<String, dynamic> nodeInfo = json.decode(response.body);

    String? nodeInfoUrl;
    if (nodeInfo['links'] != null && nodeInfo['links'].isNotEmpty) {
      for (final link in nodeInfo['links']) {
        final rel = link['rel']?.toString();
        if (rel != null && rel.contains('nodeinfo.diaspora.software/ns/schema/')) {
          nodeInfoUrl = link['href']?.toString();
          break;
        }
      }
    }

    if (nodeInfoUrl == null) return null;

    final nodeInfoResponse = await http.get(Uri.parse(nodeInfoUrl)).timeout(timeout ?? const Duration(seconds: 5));

    if (nodeInfoResponse.statusCode != 200) {
      return null;
    }

    final Map<String, dynamic> nodeInfoData = json.decode(nodeInfoResponse.body);
    final String? softwareName = nodeInfoData['software']?['name']?.toString().toLowerCase();
    final String? softwareVersion = nodeInfoData['software']?['version']?.toString();

    if (softwareName == null) return null;

    switch (softwareName) {
      case 'lemmy':
        return {'platform': ThreadiversePlatform.lemmy, 'version': softwareVersion};
      case 'piefed':
        return {'platform': ThreadiversePlatform.piefed, 'version': softwareVersion};
      default:
        return null;
    }
  } catch (e) {
    return null;
  }
}

String? _fetchInstanceNameFromUrl(String? url) {
  if (url == null) {
    return null;
  }

  final uri = Uri.parse(url);
  return uri.host;
}
