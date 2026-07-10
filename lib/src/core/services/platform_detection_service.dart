import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:thunder/src/core/domain/enums/threadiverse_platform.dart';
import 'package:thunder/src/core/networking/instance_uri.dart';

abstract class PlatformDetectionService {
  Future<Map<String, dynamic>?> detectPlatform(String instance, {Duration? timeout});
}

class NodeInfoPlatformDetectionService implements PlatformDetectionService {
  const NodeInfoPlatformDetectionService();

  @override
  Future<Map<String, dynamic>?> detectPlatform(String instance, {Duration? timeout}) {
    return detectPlatformFromNodeInfo(instance, timeout: timeout);
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
    final instanceHost = normalizeInstanceAuthority(url);
    if (instanceHost == null) return null;

    final nodeInfoUri = buildInstanceUri(instanceHost, '/.well-known/nodeinfo');

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
  } catch (_) {
    return null;
  }
}
