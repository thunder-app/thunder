import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/foundation/utils/cache/platform_version_cache.dart';
import 'package:thunder/src/features/account/api.dart';
import 'package:thunder/src/features/instance/api.dart';

typedef PlatformDetector = Future<Map<String, dynamic>?> Function(String instance, {Duration? timeout});
typedef InstanceRepositoryFactory = InstanceRepository Function(Account account);

/// Fetches the instance info for a given URL.
///
/// This includes the instance name, version, icon, and user count.
/// If the URL is invalid or the instance is unreachable, it returns a default [ThunderInstanceInfo] with success set to false.
Future<ThunderInstanceInfo> getInstanceInfo(
  String? url, {
  int? id,
  Duration? timeout,
  PlatformDetector? platformDetector,
  InstanceRepositoryFactory? instanceRepositoryFactory,
}) async {
  final instanceHost = normalizeInstanceHost(url);
  if (instanceHost == null) {
    return ThunderInstanceInfo(
      domain: '',
      name: '',
      success: false,
    );
  }

  try {
    final detector = platformDetector ?? detectPlatformFromNodeInfo;
    final repositoryFactory = instanceRepositoryFactory ?? _defaultInstanceRepositoryFactory;
    final platformInfo = await detector(instanceHost, timeout: timeout);
    final platform = platformInfo?['platform'] as ThreadiversePlatform?;
    if (platform == null) {
      return ThunderInstanceInfo(
        domain: '',
        name: '',
        success: false,
      );
    }

    PlatformVersionCache().trySet(instanceHost, platformInfo?['version']?.toString());

    final account = Account(instance: instanceHost, id: '', index: -1, platform: platform);

    final site = await repositoryFactory(account).info().timeout(timeout ?? const Duration(seconds: 5));
    final instance = site.site;

    return ThunderInstanceInfo(
      id: id,
      domain: normalizeInstanceHost(instance.actorId) ?? instanceHost,
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

InstanceRepository _defaultInstanceRepositoryFactory(Account account) => InstanceRepositoryImpl(account: account);

String? normalizeInstanceHost(String? url) {
  final trimmed = url?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;

  final lowerTrimmed = trimmed.toLowerCase();
  final value = lowerTrimmed.startsWith('http://') || lowerTrimmed.startsWith('https://') ? trimmed : 'https://$trimmed';
  final uri = Uri.tryParse(value);
  final host = uri?.host.trim().toLowerCase();
  if (host == null || host.isEmpty) return null;

  return host;
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
    final instanceHost = normalizeInstanceHost(url);
    if (instanceHost == null) return null;

    final rawUrl = url.trim().toLowerCase();
    final scheme = rawUrl.startsWith('http://') ? 'http' : 'https';
    final uri = Uri.parse('$scheme://$instanceHost');

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
