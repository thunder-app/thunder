import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:lemmy_api_client/v3.dart' hide CommentSortType;

import 'package:thunder/account/account.dart';

/// Interface for a instance repository
abstract class InstanceRepository {
  /// Fetches the site info
  /// TODO: Switch from GetSiteResponse to ThunderSite or ThunderInstance
  Future<GetSiteResponse> getSiteInfo();
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
}
