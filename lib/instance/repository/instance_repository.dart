import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:lemmy_api_client/v3.dart' hide CommentSortType;

import 'package:thunder/account/account.dart';
import 'package:thunder/core/data_providers/piefed_api.dart';
import 'package:thunder/core/enums/threadiverse_platform.dart';
import 'package:thunder/core/models/thunder_site_response.dart';
import 'package:thunder/utils/global_context.dart';

/// Interface for a instance repository
abstract class InstanceRepository {
  /// Fetches the site info
  Future<ThunderSiteResponse> getSiteInfo();

  /// Blocks a given instance
  Future<BlockInstanceResponse> block(int instanceId, bool block);

  /// Get federated instances
  Future<GetFederatedInstancesResponse> federated();
}

/// Implementation of [InstanceRepository]
class InstanceRepositoryImpl implements InstanceRepository {
  /// The account to use for methods invoked in this repository
  Account account;

  /// The Lemmy client to use for the repository
  late LemmyApiV3 client;

  /// The Piefed client to use for the repository
  late PiefedApi piefed;

  InstanceRepositoryImpl({required this.account}) {
    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        client = LemmyApiV3(account.instance, debug: kDebugMode);
        break;
      case ThreadiversePlatform.piefed:
        piefed = PiefedApi(account: account, debug: kDebugMode);
        break;
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<ThunderSiteResponse> getSiteInfo() async {
    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await client.run(GetSite(auth: account.jwt));
        return ThunderSiteResponse.fromLemmySiteResponse(response.toJson());
      case ThreadiversePlatform.piefed:
        final uri = Uri.https(account.instance, '/api/alpha/site');
        final headers = {if (account.jwt != null) 'Authorization': 'Bearer ${account.jwt}'};

        final response = await http.get(uri, headers: headers);

        final json = jsonDecode(response.body);
        return ThunderSiteResponse.fromPiefedSiteResponse(json);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<BlockInstanceResponse> block(int instanceId, bool block) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await client.run(BlockInstance(auth: account.jwt!, instanceId: instanceId, block: block));
        return response;
      case ThreadiversePlatform.piefed:
        // TODO: Implement action on Piefed
        throw Exception('This feature is not yet available');
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<GetFederatedInstancesResponse> federated() async {
    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await client.run(GetFederatedInstances(auth: account.jwt));
        return response;
      case ThreadiversePlatform.piefed:
        // TODO: Implement action on Piefed
        throw Exception('This feature is not yet available');
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }
}
