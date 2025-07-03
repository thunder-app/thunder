import 'dart:async';

import 'package:lemmy_api_client/v3.dart' hide CommentSortType;

import 'package:thunder/account/account.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';

/// Interface for a instance repository
abstract class InstanceRepository {
  /// Fetches the site info
  /// TODO: Switch from GetSiteResponse to ThunderSite or ThunderInstance
  Future<GetSiteResponse> getSiteInfo();

  /// Dispose method to clean up resources
  void dispose();
}

/// Implementation of [InstanceRepository] using Lemmy API
class LemmyInstanceRepository implements InstanceRepository {
  /// The Lemmy client to use for the repository
  LemmyApiV3 client;

  /// Stream subscription for client changes
  StreamSubscription<LemmyApiV3>? _subscription;

  LemmyInstanceRepository({required this.client}) {
    _subscription = LemmyClient.onClientChanged.listen((newClient) => client = newClient);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  Future<GetSiteResponse> getSiteInfo() async {
    final account = await fetchActiveProfile();

    final response = await client.run(GetSite(auth: account.jwt));

    return response;
  }
}
