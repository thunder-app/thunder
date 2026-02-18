import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/foundation/networking/networking.dart';
import 'package:thunder/src/foundation/errors/errors.dart';
import 'package:thunder/src/features/account/account.dart';

/// Interface for a instance repository
abstract class InstanceRepository {
  /// Fetches the site info
  Future<ThunderSiteResponse> info();

  /// Blocks a given instance
  Future<bool> block(int instanceId, bool block);

  /// Get federated instances
  Future<Map<String, dynamic>> federated();
}

/// Implementation of [InstanceRepository]
class InstanceRepositoryImpl implements InstanceRepository {
  /// The account to use for methods invoked in this repository
  final Account account;

  /// The API client to use for the repository
  final ThunderApiClient _api;

  /// Creates a new InstanceRepositoryImpl.
  ///
  /// An optional [api] client can be provided for testing.
  InstanceRepositoryImpl({required this.account, ThunderApiClient? api}) : _api = api ?? ApiClientFactory.create(account, debug: kDebugMode);

  @override
  Future<ThunderSiteResponse> info() async {
    return await _api.site();
  }

  @override
  Future<bool> block(int instanceId, bool block) async {
    final l10n = GlobalContext.l10n;
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
