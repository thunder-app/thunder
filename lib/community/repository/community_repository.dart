import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/community/models/thunder_community.dart';
import 'package:thunder/core/data_providers/piefed_api.dart';
import 'package:thunder/core/enums/feed_list_type.dart';
import 'package:thunder/core/enums/post_sort_type.dart';
import 'package:thunder/core/enums/threadiverse_platform.dart';
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
  Account account;

  /// The Lemmy client to use for the repository
  late LemmyApiV3 client;

  /// The Piefed client to use for the repository
  late PiefedApi piefed;

  CommunityRepositoryImpl({required this.account}) {
    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        client = LemmyApiV3(account.instance, debug: kDebugMode);
        break;
      case ThreadiversePlatform.piefed:
        piefed = PiefedApi(account: account, debug: kDebugMode);
        break;
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<Map<String, dynamic>> getCommunity({int? id, String? name}) async {
    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await client.run(GetCommunity(auth: account.jwt, id: id, name: name));

        return {
          'community': ThunderCommunity.fromLemmyCommunityView(response.communityView.toJson()),
          'instance': response.site != null ? ThunderSite.fromLemmySite(response.site!.toJson()) : null,
          'moderators': response.moderators.map((mod) => ThunderUser.fromLemmyUser(mod.moderator.toJson())).toList(),
        };
      case ThreadiversePlatform.piefed:
        return await piefed.getCommunity(id: id, name: name);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<ThunderCommunity> subscribe(int communityId, bool follow) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await client.run(FollowCommunity(auth: account.jwt!, communityId: communityId, follow: follow));
        return ThunderCommunity.fromLemmyCommunityView(response.communityView.toJson());
      case ThreadiversePlatform.piefed:
        return await piefed.subscribeToCommunity(communityId: communityId, follow: follow);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<ThunderCommunity> block(int communityId, bool block) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await client.run(BlockCommunity(auth: account.jwt!, communityId: communityId, block: block));
        return ThunderCommunity.fromLemmyCommunityView(response.communityView.toJson());
      case ThreadiversePlatform.piefed:
        return await piefed.blockCommunity(communityId: communityId, block: block);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<ThunderUser> banUserFromCommunity({required int userId, required bool ban, required int communityId, String? reason, int? expires, bool removeData = false}) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await client.run(BanFromCommunity(auth: account.jwt!, communityId: communityId, personId: userId, ban: ban, removeData: removeData, reason: reason, expires: expires));
        return ThunderUser.fromLemmyUserView(response.personView.toJson());
      case ThreadiversePlatform.piefed:
        return await piefed.banUserFromCommunity(userId: userId, communityId: communityId, ban: ban, reason: reason, expires: expires);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<List<ThunderUser>> addModerator({required int userId, required bool added, required int communityId}) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await client.run(AddModToCommunity(auth: account.jwt!, communityId: communityId, personId: userId, added: added));
        return response.moderators.map((mod) => ThunderUser.fromLemmyUser(mod.moderator.toJson())).toList();
      case ThreadiversePlatform.piefed:
        return await piefed.addModerator(userId: userId, communityId: communityId, added: added);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<List<ThunderCommunity>> trending() async {
    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await client.run(ListCommunities(
          type: FeedListType.local.toLemmyType(),
          sort: PostSortType.active.toLemmyType(),
          limit: 5,
          auth: account.jwt,
        ));
        return response.communities.map((cv) => ThunderCommunity.fromLemmyCommunityView(cv.toJson())).toList();
      case ThreadiversePlatform.piefed:
        return await piefed.getCommunities(page: 0, limit: 5, feedListType: FeedListType.local, postSortType: PostSortType.active);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }
}
