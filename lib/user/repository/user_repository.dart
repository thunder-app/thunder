import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/core/enums/post_sort_type.dart';
import 'package:thunder/utils/global_context.dart';

/// Interface for a user repository
abstract class UserRepository {
  /// Fetches a user by its ID
  Future<GetPersonDetailsResponse?> getUser({
    int? userId,
    String? username,
    PostSortType? sort,
    int? page,
    int? limit,
    bool? saved,
  });

  /// Blocks or unblocks a person
  Future<BlockPersonResponse> block(int personId, bool block);
}

/// Implementation of [UserRepository] using Lemmy API
class LemmyUserRepository implements UserRepository {
  /// The account to use for methods invoked in this repository
  Account account;

  /// The Lemmy client to use for the repository
  late LemmyApiV3 client;

  LemmyUserRepository({required this.account}) {
    client = LemmyApiV3(account.instance, debug: kDebugMode);
  }

  @override
  Future<GetPersonDetailsResponse?> getUser({
    int? userId,
    String? username,
    PostSortType? sort,
    int? page,
    int? limit,
    bool? saved,
  }) async {
    return await client.run(GetPersonDetails(
      auth: account.jwt,
      personId: userId,
      username: username,
      sort: sort?.toLemmyType(),
      page: page,
      limit: limit,
      savedOnly: saved,
    ));
  }

  @override
  Future<BlockPersonResponse> block(int personId, bool block) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    return client.run(BlockPerson(auth: account.jwt!, personId: personId, block: block));
  }
}
