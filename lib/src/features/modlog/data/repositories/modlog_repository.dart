import 'package:flutter/foundation.dart';

import 'package:thunder/src/foundation/foundation.dart';
import 'package:thunder/src/features/modlog/domain/models/modlog_feed.dart';
import 'package:thunder/src/features/modlog/data/models/modlog_event_item.dart';

/// Repository contract for modlog event reads.
abstract class ModlogRepository {
  Future<ModlogFeed> getModlogEvents({
    int limit = 20,
    int page = 1,
    ModlogActionType? modlogActionType,
    int? communityId,
    int? userId,
    int? moderatorId,
    int? commentId,
  });
}

/// Implementation of [ModlogRepository] using the unified API client
class ModlogRepositoryImpl implements ModlogRepository {
  /// The account to use for methods invoked in this repository
  final Account account;

  /// The API client to use for the repository
  final ThunderApiClient _api;

  /// Kept for a consistent repository constructor surface across API-backed repos.
  // ignore: unused_field
  final LocalizationService _localization;

  /// Creates a new ModlogRepositoryImpl.
  ///
  /// An optional [api] client and [localization] can be provided for testing.
  ModlogRepositoryImpl({
    required this.account,
    ThunderApiClient? api,
    LocalizationService localization = const ThunderLocalizationService(),
  })  : _api = api ?? ApiClientFactory.create(account, debug: kDebugMode),
        _localization = localization;

  @override
  Future<ModlogFeed> getModlogEvents({
    int limit = 20,
    int page = 1,
    ModlogActionType? modlogActionType,
    int? communityId,
    int? userId,
    int? moderatorId,
    int? commentId,
  }) async {
    final items = await _api.getModlog(
      page: page,
      limit: limit,
      modlogActionType: modlogActionType,
      communityId: communityId,
      userId: userId,
      moderatorId: moderatorId,
      commentId: commentId,
    );

    final modLogEventItems = items.map((event) => ModlogEventItem.fromModlogEvent(event)).toList();
    final hasReachedEnd = items.isEmpty || items.length < limit;

    return ModlogFeed(
      items: modLogEventItems,
      hasReachedEnd: hasReachedEnd,
      currentPage: page + 1,
    );
  }
}
