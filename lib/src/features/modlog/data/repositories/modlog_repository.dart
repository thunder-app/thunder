import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:thunder/src/core/network/api_client_factory.dart';
import 'package:thunder/src/core/network/thunder_api_client.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/modlog/modlog.dart';

/// Model representing a page of modlog events
class ModlogFeed {
  final List<ModlogEventItem> items;
  final bool hasReachedEnd;
  final int currentPage;

  ModlogFeed({
    required this.items,
    required this.hasReachedEnd,
    required this.currentPage,
  });
}

/// Interface for a modlog repository
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

/// Implementation of [ModlogRepository]
class ModlogRepositoryImpl implements ModlogRepository {
  /// The account to use for methods invoked in this repository
  final Account account;

  /// The API client to use for the repository
  final ThunderApiClient _api;

  /// Creates a new ModlogRepositoryImpl.
  ///
  /// An optional [api] client can be provided for testing.
  ModlogRepositoryImpl({required this.account, ThunderApiClient? api}) : _api = api ?? ApiClientFactory.create(account, debug: kDebugMode);

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

      modLogEventItems.addAll(items);

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
