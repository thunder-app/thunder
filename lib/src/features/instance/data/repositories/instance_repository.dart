import 'package:flutter/foundation.dart';

import 'package:thunder/src/foundation/foundation.dart';

/// Interface for a instance repository
abstract class InstanceRepository {
  /// Fetches the site info
  Future<ThunderSiteResponse> info();

  /// Blocks a given instance
  Future<bool> block(int instanceId, bool block);

  /// Get federated instances
  Future<Map<String, dynamic>> federated();
}

/// Implementation of [InstanceRepository] using the unified API client
class InstanceRepositoryImpl implements InstanceRepository {
  /// The account to use for methods invoked in this repository
  final Account account;

  /// The API client to use for the repository
  final ThunderApiClient _api;

  /// The localization service to use for user-facing errors
  final LocalizationService _localization;

  /// Creates a new InstanceRepositoryImpl.
  ///
  /// An optional [api] client and [localization] can be provided for testing.
  InstanceRepositoryImpl({
    required this.account,
    ThunderApiClient? api,
    LocalizationService localization = const ThunderLocalizationService(),
  })  : _api = api ?? ApiClientFactory.create(account, debug: kDebugMode),
        _localization = localization;

  @override
  Future<ThunderSiteResponse> info() async {
    return await _api.site();
  }

  @override
  Future<bool> block(int instanceId, bool block) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    if (!_api.supportsInstanceBlock) {
      throw UnsupportedFeatureException('Instance blocking', platformName: _api.platformName);
    }

    return await _api.blockInstance(instanceId: instanceId, block: block);
  }

  @override
  Future<Map<String, dynamic>> federated() async {
    return await _api.federated();
  }
}
