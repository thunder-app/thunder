import 'package:flutter/foundation.dart';

import 'package:thunder/src/foundation/contracts/account.dart';
import 'package:thunder/src/foundation/networking/networking.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';

abstract class LinkMetadataRepository {
  Future<ThunderLinkMetadata?> getLinkMetadata({required String url});
}

class LinkMetadataRepositoryImpl implements LinkMetadataRepository {
  LinkMetadataRepositoryImpl({required this.account, ThunderApiClient? api}) : _api = api ?? ApiClientFactory.create(account, debug: kDebugMode);

  /// The account to use for the link metadata
  final Account account;

  /// The API client to use for the link metadata
  final ThunderApiClient _api;

  @override
  Future<ThunderLinkMetadata?> getLinkMetadata({required String url}) async {
    final trimmedUrl = url.trim();

    if (trimmedUrl.isEmpty || account.anonymous) return null;

    try {
      return await _api.getLinkMetadata(url: trimmedUrl);
    } catch (error) {
      if (kDebugMode) debugPrint('Failed to fetch link metadata for $trimmedUrl: $error');
      return null;
    }
  }
}
