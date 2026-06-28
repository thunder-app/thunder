import 'package:flutter/foundation.dart';

import 'package:thunder/src/foundation/foundation.dart';
import 'package:thunder/src/features/modlog/domain/models/modlog_feed.dart';
import 'package:thunder/src/features/modlog/data/models/modlog_event_item.dart';
import 'package:thunder/src/features/modlog/domain/enums/enums.dart';

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
    bool hasReachedEnd = false;
    List<ModlogEventItem> modLogEventItems = [];
    int currentPage = page;

    // Guarantee that we fetch at least x events (unless we reach the end of the feed)
    do {
      final items = await _api.getModlog(
        page: currentPage,
        limit: limit,
        modlogActionType: modlogActionType,
        communityId: communityId,
        userId: userId,
        moderatorId: moderatorId,
        commentId: commentId,
      );

      modLogEventItems.addAll(items.map((event) => ModlogEventItem.fromModlogEvent(event)));

      if (items.isEmpty) hasReachedEnd = true;
      currentPage++;
    } while (!hasReachedEnd && modLogEventItems.length < limit);

    return ModlogFeed(
      items: modLogEventItems,
      hasReachedEnd: hasReachedEnd,
      currentPage: currentPage,
    );
  }
}
