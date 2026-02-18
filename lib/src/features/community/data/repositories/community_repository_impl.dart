import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:thunder/src/foundation/contracts/contracts.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/foundation/networking/networking.dart';
import 'package:thunder/src/features/community/community.dart';

/// Interface for a community repository
abstract class CommunityRepository {
  /// Fetches community information by ID or name
  Future<CommunityDetails> getCommunity({int? id, String? name});

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

  /// The localization service to use for user-facing errors
  final LocalizationService _localizationService;

  /// Creates a new CommunityRepositoryImpl.
  ///
  /// An optional [api] client can be provided for testing.
  CommunityRepositoryImpl({
    required this.account,
    ThunderApiClient? api,
    LocalizationService localizationService = const GlobalContextLocalizationService(),
  })  : _api = api ?? ApiClientFactory.create(account, debug: kDebugMode),
        _localizationService = localizationService;

  @override
  Future<CommunityDetails> getCommunity({int? id, String? name}) async {
    final response = await _api.getCommunity(id: id, name: name);
    return CommunityDetails(
      community: response.community,
      site: response.site,
      moderators: response.moderators,
      discussionLanguages: response.discussionLanguages,
    );
  }

  @override
  Future<ThunderCommunity> subscribe(int communityId, bool follow) async {
    final l10n = _localizationService.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    return await _api.subscribeToCommunity(communityId: communityId, follow: follow);
  }

  @override
  Future<ThunderCommunity> block(int communityId, bool block) async {
    final l10n = _localizationService.l10n;
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
    final l10n = _localizationService.l10n;
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
    final l10n = _localizationService.l10n;
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
