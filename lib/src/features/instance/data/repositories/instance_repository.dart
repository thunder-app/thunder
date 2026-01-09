import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:thunder/src/core/cache/platform_version_cache.dart';
import 'package:thunder/src/core/network/lemmy_api.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/core/network/piefed_api.dart';
import 'package:thunder/src/core/enums/threadiverse_platform.dart';
import 'package:thunder/src/core/models/thunder_site_response.dart';
import 'package:thunder/src/app/utils/global_context.dart';

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
  Account account;

  /// The Lemmy client to use for the repository
  late LemmyApi client;

  /// The Piefed client to use for the repository
  late PiefedApi piefed;

  InstanceRepositoryImpl({required this.account}) {
    final version = PlatformVersionCache().get(account.instance);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        client = LemmyApi(account: account, debug: kDebugMode, version: version);
        break;
      case ThreadiversePlatform.piefed:
        piefed = PiefedApi(account: account, debug: kDebugMode, version: version);
        break;
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<ThunderSiteResponse> info() async {
    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await client.site();
      case ThreadiversePlatform.piefed:
        return await piefed.site();
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<bool> block(int instanceId, bool block) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await client.blockInstance(instanceId: instanceId, block: block);
      case ThreadiversePlatform.piefed:
        return await piefed.blockInstance(instanceId: instanceId, block: block);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<Map<String, dynamic>> federated() async {
    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await client.federated();
      case ThreadiversePlatform.piefed:
        // TODO: Implement action on Piefed
        throw Exception('This feature is not yet available');
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }
}
