import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
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
  Future<BlockCommunityResponse> block(int communityId, bool block);

  /// Bans or unbans a user from a community
  ///
  /// Can optionally provide a reason and expiration date (in seconds)
  /// If [removeData] is true, posts and comments from the user will also be deleted
  Future<BanFromCommunityResponse> banUserFromCommunity({required int userId, required bool ban, required int communityId, String? reason, int? expires, bool removeData = false});

  /// Adds or removes a moderator from a community
  Future<AddModToCommunityResponse> addModerator({required int userId, required bool added, required int communityId});
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
        Map<String, dynamic> body = {
          'id': id,
          'name': name,
        };

        // Remove null values and convert values to strings
        body.removeWhere((key, value) => value == null);
        body = body.map((key, value) => MapEntry(key, value.toString()));

        final uri = Uri.https(account.instance, '/api/alpha/community', body);
        final headers = {if (account.jwt != null) 'Authorization': 'Bearer ${account.jwt}'};

        final response = await http.get(uri, headers: headers);

        final json = jsonDecode(response.body);

        return {
          'community': ThunderCommunity.fromPiefedCommunityView(json['community_view']),
          'site': json['site'] != null ? ThunderSite.fromPiefedSite(json['site']) : null,
          'moderators': json['moderators'].map<ThunderUser>((cmv) => ThunderUser.fromPiefedUser(cmv['moderator'])).toList(),
          'discussion_languages': json['discussion_languages'],
        };
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
        // TODO: Implement action on Piefed
        throw Exception('This feature is not yet available');
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<BlockCommunityResponse> block(int communityId, bool block) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await client.run(BlockCommunity(auth: account.jwt!, communityId: communityId, block: block));
        return response;
      case ThreadiversePlatform.piefed:
        // TODO: Implement action on Piefed
        throw Exception('This feature is not yet available');
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<BanFromCommunityResponse> banUserFromCommunity({required int userId, required bool ban, required int communityId, String? reason, int? expires, bool removeData = false}) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await client.run(BanFromCommunity(auth: account.jwt!, communityId: communityId, personId: userId, ban: ban, removeData: removeData, reason: reason, expires: expires));
        return response;
      case ThreadiversePlatform.piefed:
        // TODO: Implement action on Piefed
        throw Exception('This feature is not yet available');
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<AddModToCommunityResponse> addModerator({required int userId, required bool added, required int communityId}) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await client.run(AddModToCommunity(auth: account.jwt!, communityId: communityId, personId: userId, added: added));
        return response;
      case ThreadiversePlatform.piefed:
        // TODO: Implement action on Piefed
        throw Exception('This feature is not yet available');
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
        // TODO: Implement action on Piefed
        throw Exception('This feature is not yet available');
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }
}
