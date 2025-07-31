import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/community/models/thunder_community.dart';
import 'package:thunder/core/enums/feed_list_type.dart';
import 'package:thunder/core/enums/post_sort_type.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/user/models/thunder_user.dart';
import 'package:thunder/utils/global_context.dart';

/// Interface for a community repository
abstract class CommunityRepository {
  /// Fetches community information by ID or name
  Future<Map<String, dynamic>> getCommunity({int? id, String? name});

  /// Lists trending communities
  Future<List<ThunderCommunity>> trending();

  /// Follows or unfollows a community
  Future<ThunderCommunity> subscribe(int communityId, bool follow);

  /// Blocks or unblocks a community
  Future<BlockCommunityResponse> block(int communityId, bool block);

  /// Bans or unbans a user from a community
  ///
  /// Can optionally provide a reason and expiration date (in seconds)
  /// If [removeData] is true, posts and comments from the user will also be deleted
  Future<BanFromCommunityResponse> banUserFromCommunity({required int userId, required bool ban, required int communityId, String? reason, int? expires, bool removeData = false});

  /// Adds or removes a moderator from a community
  Future<AddModToCommunityResponse> addModerator({required int userId, required bool added, required int communityId});
}

/// Implementation of [CommunityRepository] using Lemmy API
class LemmyCommunityRepository implements CommunityRepository {
  /// The account to use for methods invoked in this repository
  Account account;

  /// The Lemmy client to use for the repository
  late LemmyApiV3 client;

  LemmyCommunityRepository({required this.account}) {
    client = LemmyApiV3(account.instance, debug: kDebugMode);
  }

  @override
  Future<Map<String, dynamic>> getCommunity({int? id, String? name}) async {
    assert(!(id == null && name == null));
    final response = await client.run(GetCommunity(auth: account.jwt, id: id, name: name));

    return {
      "community": ThunderCommunity.fromLemmyCommunityView(response.communityView.toJson()),
      "instance": response.site != null ? ThunderSite.fromLemmySite(response.site!.toJson()) : null,
      "moderators": response.moderators.map((mod) => ThunderUser.fromLemmyUser(mod.moderator.toJson())).toList(),
    };
  }

  @override
  Future<ThunderCommunity> subscribe(int communityId, bool follow) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final response = await client.run(FollowCommunity(auth: account.jwt!, communityId: communityId, follow: follow));
    return ThunderCommunity.fromLemmyCommunityView(response.communityView.toJson());
  }

  @override
  Future<BlockCommunityResponse> block(int communityId, bool block) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    return await client.run(BlockCommunity(auth: account.jwt!, communityId: communityId, block: block));
  }

  @override
  Future<BanFromCommunityResponse> banUserFromCommunity({required int userId, required bool ban, required int communityId, String? reason, int? expires, bool removeData = false}) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final response = await client.run(BanFromCommunity(auth: account.jwt!, communityId: communityId, personId: userId, ban: ban, removeData: removeData, reason: reason, expires: expires));
    return response;
  }

  @override
  Future<AddModToCommunityResponse> addModerator({required int userId, required bool added, required int communityId}) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final response = await client.run(AddModToCommunity(auth: account.jwt!, communityId: communityId, personId: userId, added: added));
    return response;
  }

  @override
  Future<List<ThunderCommunity>> trending() async {
    final response = await client.run(ListCommunities(
      type: FeedListType.local.toLemmyType(),
      sort: PostSortType.active.toLemmyType(),
      limit: 5,
      auth: account.jwt,
    ));

    return response.communities.map((cv) => ThunderCommunity.fromLemmyCommunityView(cv.toJson())).toList();
  }
}
