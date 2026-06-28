import 'package:flutter/foundation.dart';

import 'package:thunder/src/foundation/contracts/account.dart';
import 'package:thunder/src/foundation/networking/api_client_factory.dart';
import 'package:thunder/src/foundation/networking/thunder_api_client.dart';

/// Lazily resolves a [ThunderApiClient], including async version probing.
class ResolvedApiClient {
  ResolvedApiClient._(this._future);

  final Future<ThunderApiClient> _future;
  ThunderApiClient? _cached;

  factory ResolvedApiClient({
    required Account account,
    ThunderApiClient? api,
    bool debug = kDebugMode,
  }) {
    return ResolvedApiClient._(
      api != null ? Future.value(api) : ApiClientFactory.create(account, debug: debug),
    );
  }

  Future<ThunderApiClient> get() async => _cached ??= await _future;
}
