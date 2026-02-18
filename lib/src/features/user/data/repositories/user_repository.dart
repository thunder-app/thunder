import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/foundation/networking/networking.dart';
import 'package:thunder/src/features/account/account.dart';

/// Interface for a user repository
abstract class UserRepository {
  /// Fetches a user by its ID
  Future<Map<String, dynamic>?> getUser({
    int? userId,
    String? username,
    PostSortType? sort,
    int? page,
    int? limit,
    bool? saved,
    bool? includeContent,
  });

  /// Blocks or unblocks a person
  Future<ThunderUser> block(int personId, bool block);
}

/// Implementation of [UserRepository] using the unified API client
class UserRepositoryImpl implements UserRepository {
  /// The account to use for methods invoked in this repository
  final Account account;

  /// The API client to use for the repository
  final ThunderApiClient _api;

  /// Creates a new UserRepositoryImpl.
  ///
  /// An optional [api] client can be provided for testing.
  UserRepositoryImpl({required this.account, ThunderApiClient? api}) : _api = api ?? ApiClientFactory.create(account, debug: kDebugMode);

  @override
  Future<Map<String, dynamic>?> getUser({
    int? userId,
    String? username,
    PostSortType? sort,
    int? page,
    int? limit,
    bool? saved,
    bool? includeContent,
  }) async {
    final response = await _api.getUser(
      userId: userId,
      username: username,
      sort: sort,
      page: page,
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
    };
  }

  @override
  Future<ThunderUser> block(int personId, bool block) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    return await _api.blockUser(userId: personId, block: block);
  }
}
