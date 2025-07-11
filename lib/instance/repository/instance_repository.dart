import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:lemmy_api_client/v3.dart' hide CommentSortType;

import 'package:thunder/account/account.dart';
import 'package:thunder/utils/global_context.dart';

/// Interface for a instance repository
abstract class InstanceRepository {
  /// Fetches the site info
  /// TODO: Switch from GetSiteResponse to ThunderSite or ThunderInstance
  Future<GetSiteResponse> getSiteInfo();

  /// Blocks a given instance
  Future<BlockInstanceResponse> block(int instanceId, bool block);

  /// Get federated instances
  Future<GetFederatedInstancesResponse> federated();
}

/// Implementation of [InstanceRepository] using Lemmy API
class LemmyInstanceRepository implements InstanceRepository {
  /// The account to use for methods invoked in this repository
  Account account;

  /// The Lemmy client to use for the repository
  late LemmyApiV3 client;

  LemmyInstanceRepository({required this.account}) {
    client = LemmyApiV3(account.instance, debug: kDebugMode);
  }

  @override
  Future<GetSiteResponse> getSiteInfo() async {
    final response = await client.run(GetSite(auth: account.jwt));

    return response;
  }

  @override
  Future<BlockInstanceResponse> block(int instanceId, bool block) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final response = await client.run(BlockInstance(auth: account.jwt!, instanceId: instanceId, block: block));

    return response;
  }

  @override
  Future<GetFederatedInstancesResponse> federated() async {
    final response = await client.run(GetFederatedInstances(auth: account.jwt));
    return response;
  }
}
