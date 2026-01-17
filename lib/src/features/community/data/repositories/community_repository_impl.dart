import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:thunder/src/app/utils/global_context.dart';
import 'package:thunder/src/core/enums/feed_list_type.dart';
import 'package:thunder/src/core/enums/post_sort_type.dart';
import 'package:thunder/src/core/network/api_client_factory.dart';
import 'package:thunder/src/core/network/thunder_api_client.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/features/user/user.dart';

/// Interface for a community repository
abstract class CommunityRepository {
  /// Fetches community information by ID or name
  Future<Map<String, dynamic>> getCommunity({int? id, String? name});

  /// Lists trending communities
  Future<List<ThunderCommunity>> trending();

  /// Follows or unfollows a community
  Future<ThunderCommunity> subscribe(int communityId, bool follow);

  /// Blocks or unblocks a community
  Future<ThunderCommunity> block(int communityId, bool block);

  /// Bans or unbans a user from a community
  ///
  /// Can optionally provide a reason and expiration date (in seconds)
  /// If [removeData] is true, posts and comments from the user will also be deleted
  Future<ThunderUser> banUserFromCommunity({required int userId, required bool ban, required int communityId, String? reason, int? expires, bool removeData = false});

  /// Adds or removes a moderator from a community
  Future<List<ThunderUser>> addModerator({required int userId, required bool added, required int communityId});
}

/// Implementation of [CommunityRepository]
class CommunityRepositoryImpl implements CommunityRepository {
  /// The account to use for methods invoked in this repository
  final Account account;

  /// The API client to use for the repository
  final ThunderApiClient _api;

  /// Creates a new CommunityRepositoryImpl.
  ///
  /// An optional [api] client can be provided for testing.
  CommunityRepositoryImpl({required this.account, ThunderApiClient? api}) : _api = api ?? ApiClientFactory.create(account, debug: kDebugMode);

  @override
  Future<Map<String, dynamic>> getCommunity({int? id, String? name}) async {
    final response = await _api.getCommunity(id: id, name: name);
    return {
      'community': response.community,
      'site': response.site,
      'moderators': response.moderators,
      'discussion_languages': response.discussionLanguages,
    };
  }

  @override
  Future<ThunderCommunity> subscribe(int communityId, bool follow) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    return await _api.subscribeToCommunity(communityId: communityId, follow: follow);
  }

  @override
  Future<ThunderCommunity> block(int communityId, bool block) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    return await _api.blockCommunity(communityId: communityId, block: block);
  }

  @override
  Future<ThunderUser> banUserFromCommunity({
    required int userId,
    required bool ban,
    required int communityId,
    String? reason,
    int? expires,
    bool removeData = false,
  }) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    return await _api.banUserFromCommunity(
      userId: userId,
      communityId: communityId,
      ban: ban,
      removeData: removeData,
      reason: reason,
      expires: expires,
    );
  }

  @override
  Future<List<ThunderUser>> addModerator({
    required int userId,
    required bool added,
    required int communityId,
  }) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    return await _api.addModerator(
      userId: userId,
      communityId: communityId,
      added: added,
    );
  }

  @override
  Future<List<ThunderCommunity>> trending() async {
    return await _api.getCommunities(
      page: 1,
      limit: 5,
      feedListType: FeedListType.local,
      postSortType: PostSortType.active,
    );
  }
}
