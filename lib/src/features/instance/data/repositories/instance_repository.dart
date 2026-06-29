import 'package:thunder/src/foundation/foundation.dart';
import 'package:thunder/src/foundation/networking/resolved_api_client.dart';
import 'package:thunder/src/features/instance/domain/models/federated_instances.dart';

/// Repository contract for instance site reads and blocks.
abstract class InstanceRepository {
  /// Fetches the site info
  Future<ThunderSiteResponse> info();

  /// Blocks a given instance
  Future<bool> block(int instanceId, bool block);

  /// Get federated instances
  Future<FederatedInstances> federated();
}

/// Implementation of [InstanceRepository] using the unified API client
class InstanceRepositoryImpl implements InstanceRepository {
  /// The account to use for methods invoked in this repository
  final Account account;

  /// The API client to use for the repository
  final ResolvedApiClient _api;

  /// The localization service to use for user-facing errors
  final LocalizationService _localization;

  /// Creates a new InstanceRepositoryImpl.
  ///
  /// An optional [api] client and [localization] can be provided for testing.
  InstanceRepositoryImpl({
    required this.account,
    ThunderApiClient? api,
    LocalizationService localization = const ThunderLocalizationService(),
  })  : _api = ResolvedApiClient(account: account, api: api),
        _localization = localization;

  @override
  Future<ThunderSiteResponse> info() async {
    final api = await _api.get();
    return api.site();
  }

  @override
  Future<bool> block(int instanceId, bool block) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    return api.blockInstance(instanceId: instanceId, block: block);
  }

  @override
  Future<FederatedInstances> federated() async {
    final api = await _api.get();
    final response = await api.federated();
    return FederatedInstances.fromJson(response);
  }
}
