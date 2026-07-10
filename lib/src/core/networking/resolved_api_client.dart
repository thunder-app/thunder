import 'package:flutter/foundation.dart';

import 'package:thunder/src/core/domain/models/account.dart';
import 'package:thunder/src/core/networking/api_client_factory.dart';
import 'package:thunder/src/core/networking/thunder_api_client.dart';

/// Lazily resolves a [ThunderApiClient], including async version probing.
class ResolvedApiClient {
  ResolvedApiClient._(this._resolve);

  @visibleForTesting
  ResolvedApiClient.fromResolver(Future<ThunderApiClient> Function() resolve) : this._(resolve);

  final Future<ThunderApiClient> Function() _resolve;
  Future<ThunderApiClient>? _future;
  ThunderApiClient? _cached;

  factory ResolvedApiClient({
    required Account account,
    ThunderApiClient? api,
    bool debug = kDebugMode,
  }) {
    return ResolvedApiClient._(
      () => api != null ? Future.value(api) : ApiClientFactory.create(account, debug: debug),
    );
  }

  Future<ThunderApiClient> get() async {
    final cached = _cached;
    if (cached != null) return cached;

    final future = _future ??= _resolve();
    return _cached ??= await future;
  }
}
