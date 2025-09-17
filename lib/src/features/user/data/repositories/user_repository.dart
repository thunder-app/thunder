import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:thunder/src/core/cache/platform_version_cache.dart';
import 'package:thunder/src/core/network/lemmy_api.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/core/network/piefed_api.dart';
import 'package:thunder/src/core/enums/post_sort_type.dart';
import 'package:thunder/src/core/enums/threadiverse_platform.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/app/utils/global_context.dart';

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
  });

  /// Blocks or unblocks a person
  Future<ThunderUser> block(int personId, bool block);
}

/// Implementation of [UserRepository] using Lemmy API
class UserRepositoryImpl implements UserRepository {
  /// The account to use for methods invoked in this repository
  Account account;

  /// The Lemmy client to use for the repository
  late LemmyApi client;

  /// The Piefed client to use for the repository
  late PiefedApi piefed;

  UserRepositoryImpl({required this.account}) {
    final version = PlatformVersionCache().get(account.instance);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        client = LemmyApi(account: account, debug: kDebugMode, version: version);
        break;
      case ThreadiversePlatform.piefed:
        piefed = PiefedApi(account: account, debug: kDebugMode, version: version);
        break;
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<Map<String, dynamic>?> getUser({
    int? userId,
    String? username,
    PostSortType? sort,
    int? page,
    int? limit,
    bool? saved,
  }) async {
    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await client.getUser(userId: userId, username: username, sort: sort, page: page, limit: limit, saved: saved);
      case ThreadiversePlatform.piefed:
        return await piefed.getUser(userId: userId, username: username, sort: sort, page: page, limit: limit, saved: saved);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<ThunderUser> block(int personId, bool block) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await client.blockUser(userId: personId, block: block);
      case ThreadiversePlatform.piefed:
        return await piefed.blockUser(userId: personId, block: block);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }
}
