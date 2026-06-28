import 'package:flutter/foundation.dart';

import 'package:thunder/src/foundation/foundation.dart';

abstract class UserRepository {
  /// Fetches a user by their id or username
  Future<Map<String, dynamic>?> getUser({
    int? userId,
    String? username,
    PostSortType? sort,
    int? page,
    String? cursor,
    int? limit,
    bool? saved,
    bool? includeContent,
  });

  /// Blocks or unblocks a user
  Future<ThunderUser> blockUser(int userId, bool block);
}

/// Implementation of [UserRepository] using the unified API client
class UserRepositoryImpl implements UserRepository {
  /// The account to use for methods invoked in this repository
  final Account account;

  /// The API client to use for the repository
  final ThunderApiClient _api;

  /// The localization service to use for user-facing errors
  final LocalizationService _localization;

  /// Creates a new UserRepositoryImpl.
  ///
  /// An optional [api] client and [localization] can be provided for testing.
  UserRepositoryImpl({
    required this.account,
    ThunderApiClient? api,
    LocalizationService localization = const ThunderLocalizationService(),
  })  : _api = api ?? ApiClientFactory.create(account, debug: kDebugMode),
        _localization = localization;

  @override
  Future<Map<String, dynamic>?> getUser({
    int? userId,
    String? username,
    PostSortType? sort,
    int? page,
    String? cursor,
    int? limit,
    bool? saved,
    bool? includeContent,
  }) async {
    final response = await _api.getUser(
      userId: userId,
      username: username,
      sort: sort,
      page: page,
      cursor: cursor,
      limit: limit,
      saved: saved,
      includeContent: includeContent,
    );

    return {
      'user': response.user,
      'site': response.site,
      'posts': response.posts,
      'comments': response.comments,
      'moderates': response.moderates,
      'next_page': response.nextPage,
    };
  }

  @override
  Future<ThunderUser> blockUser(int userId, bool block) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    return await _api.blockUser(userId: userId, block: block);
  }
}
