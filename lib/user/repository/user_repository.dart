import 'dart:async';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/core/enums/post_sort_type.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
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

  /// Dispose method to clean up resources
  void dispose();
}

/// Implementation of [UserRepository] using Lemmy API
class LemmyUserRepository implements UserRepository {
  /// The Lemmy client to use for the repository
  LemmyApiV3 client;

  /// Stream subscription for client changes
  StreamSubscription<LemmyApiV3>? _subscription;

  LemmyUserRepository({required this.client}) {
    _subscription = LemmyClient.onClientChanged.listen((newClient) => client = newClient);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
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
    final account = await fetchActiveProfile();

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
    final account = await fetchActiveProfile();
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    return client.run(BlockPerson(auth: account.jwt!, personId: personId, block: block));
  }
}
