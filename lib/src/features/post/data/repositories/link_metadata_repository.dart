import 'package:flutter/foundation.dart';

import 'package:thunder/src/core/core.dart';
import 'package:thunder/src/core/networking/resolved_api_client.dart';

/// Repository contract for link metadata reads.
abstract class LinkMetadataRepository {
  /// Fetches the metadata for a given URL.
  Future<ThunderLinkMetadata?> getLinkMetadata({required String url});
}

/// Implementation of [LinkMetadataRepository] using the unified API client
class LinkMetadataRepositoryImpl implements LinkMetadataRepository {
  /// The account to use for methods invoked in this repository
  final Account account;

  /// The API client to use for the repository
  final ResolvedApiClient _api;

  /// Kept for a consistent repository constructor surface across API-backed repos.
  // ignore: unused_field
  final LocalizationService _localization;

  /// Creates a new LinkMetadataRepositoryImpl.
  ///
  /// An optional [api] client and [localization] can be provided for testing.
  LinkMetadataRepositoryImpl({
    required this.account,
    ThunderApiClient? api,
    LocalizationService localization = const ThunderLocalizationService(),
  })  : _api = ResolvedApiClient(account: account, api: api),
        _localization = localization;

  @override
  Future<ThunderLinkMetadata?> getLinkMetadata({required String url}) async {
    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty || account.anonymous) return null;

    final api = await _api.get();
    try {
      return api.getLinkMetadata(url: trimmedUrl);
    } catch (error) {
      if (kDebugMode) debugPrint('Failed to fetch link metadata for $trimmedUrl: $error');
      return null;
    }
  }
}
