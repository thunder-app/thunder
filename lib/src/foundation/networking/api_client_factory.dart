import 'package:http/http.dart' as http;
import 'package:version/version.dart';

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
/// final api = ApiClientFactory.create(account);
/// final posts = await api.getPosts();
/// ```
class ApiClientFactory {
  /// Create a new API client for the given account.
  ///
  /// The factory will automatically select the appropriate client based on:
  /// - The account's platform (Lemmy, PieFed, etc.)
  /// - The instance's API version (from PlatformVersionCache)
  static ThunderApiClient create(
    Account account, {
    bool debug = false,
    http.Client? httpClient,
  }) {
    return switch (account.platform) {
      ThreadiversePlatform.lemmy => _createLemmyClient(account, debug, httpClient),
      ThreadiversePlatform.piefed => _createPiefedClient(account, debug, httpClient),
      _ => throw UnsupportedError('Unsupported platform: ${account.platform}'),
    };
  }

  /// Create the appropriate Lemmy client based on version.
  static ThunderApiClient _createLemmyClient(
    Account account,
    bool debug,
    http.Client? httpClient,
  ) {
    final version = PlatformVersionCache().get(account.instance);

    // Check if the instance requires v4 API (Lemmy 1.0.0+)
    if (version != null && _isLemmyApiV4(version)) {
      return LemmyV4ApiClient(
        account: account,
        debug: debug,
        version: version,
        httpClient: httpClient,
      );
    }

    // Default to v3 API for older instances or when version is unknown
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
    final version = PlatformVersionCache().get(account.instance);

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
  static ThunderApiClient createForTesting({
    required Account account,
    required http.Client mockHttpClient,
    bool debug = false,
  }) {
    return create(account, debug: debug, httpClient: mockHttpClient);
  }
}
