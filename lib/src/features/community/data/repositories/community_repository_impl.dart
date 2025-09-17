import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:thunder/src/core/cache/platform_version_cache.dart';
import 'package:thunder/src/core/network/lemmy_api.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/core/network/piefed_api.dart';
import 'package:thunder/src/core/enums/feed_list_type.dart';
import 'package:thunder/src/core/enums/post_sort_type.dart';
import 'package:thunder/src/core/enums/threadiverse_platform.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/app/utils/global_context.dart';

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
  late LemmyApi client;

  /// The Piefed client to use for the repository
  late PiefedApi piefed;

  CommunityRepositoryImpl({required this.account}) {
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
  Future<Map<String, dynamic>> getCommunity({int? id, String? name}) async {
    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await client.getCommunity(id: id, name: name);
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
        return await client.subscribeToCommunity(communityId: communityId, follow: follow);
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
        return await client.blockCommunity(communityId: communityId, block: block);
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
        return await client.banUserFromCommunity(userId: userId, communityId: communityId, ban: ban, removeData: removeData, reason: reason, expires: expires);
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
        return await client.addModerator(userId: userId, communityId: communityId, added: added);
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
        return await client.getCommunities(page: 1, limit: 5, feedListType: FeedListType.local, postSortType: PostSortType.active);
      case ThreadiversePlatform.piefed:
        return await piefed.getCommunities(page: 1, limit: 5, feedListType: FeedListType.local, postSortType: PostSortType.new_);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }
}
