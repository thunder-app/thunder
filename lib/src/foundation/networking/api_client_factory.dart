import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:version/version.dart';

import 'package:thunder/src/foundation/networking/instance_uri.dart';
import 'package:thunder/src/foundation/utils/cache/platform_version_cache.dart';
import 'package:thunder/src/foundation/primitives/enums/threadiverse_platform.dart';
import 'package:thunder/src/foundation/networking/lemmy/lemmy_v3_api_client.dart';
import 'package:thunder/src/foundation/networking/lemmy/lemmy_v4_api_client.dart';
import 'package:thunder/src/foundation/networking/piefed/piefed_api_client.dart';
import 'package:thunder/src/foundation/networking/thunder_api_client.dart';
import 'package:thunder/src/foundation/contracts/account.dart';

/// Factory for creating the appropriate API client based on platform and version.
///
/// Example usage:
/// ```dart
/// final api = await ApiClientFactory.create(account);
/// final posts = await api.getPosts();
/// ```
class ApiClientFactory {
  /// Create a new API client for the given account.
  ///
  /// The factory will automatically select the appropriate client based on:
  /// - The account's platform (Lemmy, PieFed, etc.)
  /// - The instance's API version (from PlatformVersionCache)
  static Future<ThunderApiClient> create(
    Account account, {
    bool debug = false,
    http.Client? httpClient,
  }) async {
    return switch (account.platform) {
      ThreadiversePlatform.lemmy => _createLemmyClient(account, debug, httpClient),
      ThreadiversePlatform.piefed => Future.value(_createPiefedClient(account, debug, httpClient)),
      _ => throw UnsupportedError('Unsupported platform: ${account.platform}'),
    };
  }

  /// Probes Lemmy `/site` endpoints to discover and cache the instance version.
  static Future<Version?> probeLemmySiteVersion(
    String instance, {
    http.Client? httpClient,
  }) async {
    final normalizedInstance = normalizeInstanceAuthority(instance) ?? instance;
    final client = httpClient ?? http.Client();
    final ownsClient = httpClient == null;

    try {
      for (final path in const ['/api/v4/site', '/api/v3/site']) {
        try {
          final response = await client.get(buildInstanceUri(normalizedInstance, path)).timeout(const Duration(seconds: 5));
          if (response.statusCode != 200) continue;

          final decoded = jsonDecode(response.body);
          if (decoded is! Map<String, dynamic>) continue;

          final versionString = decoded['version']?.toString();
          if (versionString == null || versionString.isEmpty) continue;

          PlatformVersionCache().trySet(normalizedInstance, versionString);
          return Version.parse(versionString);
        } catch (_) {
          continue;
        }
      }
    } finally {
      if (ownsClient) {
        client.close();
      }
    }

    return null;
  }

  /// Create the appropriate Lemmy client based on version.
  static Future<ThunderApiClient> _createLemmyClient(
    Account account,
    bool debug,
    http.Client? httpClient,
  ) async {
    final normalizedInstance = normalizeInstanceAuthority(account.instance) ?? account.instance;
    var version = PlatformVersionCache().get(normalizedInstance);
    version ??= await probeLemmySiteVersion(normalizedInstance, httpClient: httpClient);

    if (version != null && _isLemmyApiV4(version)) {
      return LemmyV4ApiClient(
        account: account,
        debug: debug,
        version: version,
        httpClient: httpClient,
      );
    }

    return LemmyV3ApiClient(
      account: account,
      debug: debug,
      version: version,
      httpClient: httpClient,
    );
  }

  /// Create a PieFed client.
  static ThunderApiClient _createPiefedClient(
    Account account,
    bool debug,
    http.Client? httpClient,
  ) {
    final normalizedInstance = normalizeInstanceAuthority(account.instance) ?? account.instance;
    final version = PlatformVersionCache().get(normalizedInstance);

    return PiefedApiClient(
      account: account,
      debug: debug,
      version: version,
      httpClient: httpClient,
    );
  }

  /// Check if the Lemmy version requires the v4 API.
  ///
  /// Lemmy 1.0.0+ uses the v4 API. Pre-releases (alpha, beta, rc) of 1.0.0 should also use v4.
  static bool _isLemmyApiV4(Version version) {
    return version.major >= 1;
  }

  /// Create a mock client for testing.
  static Future<ThunderApiClient> createForTesting({
    required Account account,
    required http.Client mockHttpClient,
    bool debug = false,
  }) {
    return create(account, debug: debug, httpClient: mockHttpClient);
  }
}
