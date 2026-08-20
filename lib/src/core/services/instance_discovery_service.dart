import 'package:flutter/foundation.dart';

import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/core/networking/instance_uri.dart';
import 'package:thunder/src/core/services/platform_detection_service.dart';
import 'package:thunder/src/core/utils/platform_version_cache.dart';
import 'package:thunder/src/features/instance/api.dart';
import 'package:thunder/src/core/app/repository_factories.dart';

typedef PlatformDetector = Future<Map<String, dynamic>?> Function(String instance, {Duration? timeout});
typedef InstanceRepositoryFactory = InstanceRepository Function(Account account);

/// Fetches the instance info for a given URL.
///
/// This includes the instance name, version, icon, and user count.
/// If the URL is invalid or the instance is unreachable, it returns a default [ThunderInstanceInfo] with success set to false.
Future<ThunderInstanceInfo> getInstanceInfo(String? url, {int? id, Duration? timeout, PlatformDetector? platformDetector, InstanceRepositoryFactory? instanceRepositoryFactory}) async {
  final discovery = await discoverInstance(url, timeout: timeout, platformDetector: platformDetector);
  if (discovery == null) {
    return ThunderInstanceInfo(domain: '', name: '', success: false);
  }

  return loadInstanceInfo(discovery, id: id, timeout: timeout, instanceRepositoryFactory: instanceRepositoryFactory);
}

/// Detects a supported instance and immediately caches its platform version.
Future<InstanceDiscoveryResult?> discoverInstance(String? url, {Duration? timeout, PlatformDetector? platformDetector}) async {
  final instanceHost = normalizeInstanceHost(url);
  if (instanceHost == null) return null;

  try {
    final detector = platformDetector ?? detectPlatformFromNodeInfo;
    final platformInfo = await detector(instanceHost, timeout: timeout);
    final platform = platformInfo?['platform'] as ThreadiversePlatform?;
    if (platform == null) return null;

    final version = platformInfo?['version']?.toString();
    PlatformVersionCache().trySet(instanceHost, version);

    return InstanceDiscoveryResult(host: instanceHost, platform: platform, version: version);
  } catch (_) {
    return null;
  }
}

/// Loads full site metadata for an already detected [discovery].
///
/// This function does not repeat NodeInfo detection.
Future<ThunderInstanceInfo> loadInstanceInfo(InstanceDiscoveryResult discovery, {int? id, Duration? timeout, InstanceRepositoryFactory? instanceRepositoryFactory}) async {
  try {
    final repositoryFactory = instanceRepositoryFactory ?? _defaultInstanceRepositoryFactory;
    final account = Account(instance: discovery.host, id: '', index: -1, platform: discovery.platform);

    final site = await repositoryFactory(account).info().timeout(timeout ?? const Duration(seconds: 5));
    final instance = site.site;

    return ThunderInstanceInfo(
      id: id,
      domain: normalizeInstanceHost(instance.actorId) ?? discovery.host,
      version: site.version,
      name: instance.name,
      icon: instance.icon,
      users: instance.users,
      success: true,
      platform: discovery.platform,
      contentWarning: site.site.contentWarning,
    );
  } catch (e) {
    debugPrint('Error getting instance info: $e');

    return ThunderInstanceInfo(domain: discovery.host, name: discovery.host, version: discovery.version, platform: discovery.platform, success: false);
  }
}

InstanceRepository _defaultInstanceRepositoryFactory(Account account) => createInstanceRepository(account);

String? normalizeInstanceHost(String? url) {
  return normalizeInstanceAuthority(url);
}
