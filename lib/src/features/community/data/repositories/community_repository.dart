import 'package:flutter/foundation.dart';

import 'package:thunder/src/foundation/foundation.dart';
import 'package:thunder/src/features/community/community.dart';

/// Repository contract for community reads and moderation actions.
abstract class CommunityRepository {
  /// Fetches community information by ID or name
  Future<CommunityDetail> getCommunity({int? id, String? name});

  /// Lists trending communities
  Future<List<ThunderCommunity>> trending({
    int page = 1,
    int limit = 5,
    FeedListType feedListType = FeedListType.local,
    PostSortType postSortType = PostSortType.active,
  });

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

/// Implementation of [CommunityRepository] using the unified API client
class CommunityRepositoryImpl implements CommunityRepository {
  /// The account to use for methods invoked in this repository
  final Account account;

  /// The API client to use for the repository
  final ThunderApiClient _api;

  /// The localization service to use for user-facing errors
  final LocalizationService _localization;

  /// Creates a new CommunityRepositoryImpl.
  ///
  /// An optional [api] client and [localization] can be provided for testing.
  CommunityRepositoryImpl({
    required this.account,
    ThunderApiClient? api,
    LocalizationService localization = const ThunderLocalizationService(),
  })  : _api = api ?? ApiClientFactory.create(account, debug: kDebugMode),
        _localization = localization;

  @override
  Future<CommunityDetail> getCommunity({int? id, String? name}) async {
    final response = await _api.getCommunity(id: id, name: name);
    return CommunityDetail(
      community: response.community,
      site: response.site,
      moderators: response.moderators,
      discussionLanguages: response.discussionLanguages,
      flairs: response.flairs,
    );
  }

  @override
  Future<ThunderCommunity> subscribe(int communityId, bool follow) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    return _api.subscribeToCommunity(communityId: communityId, follow: follow);
  }

  @override
  Future<ThunderCommunity> block(int communityId, bool block) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    return _api.blockCommunity(communityId: communityId, block: block);
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
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    return _api.banUserFromCommunity(
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
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    return _api.addModerator(
      userId: userId,
      communityId: communityId,
      added: added,
    );
  }

  @override
  Future<List<ThunderCommunity>> trending({
    int page = 1,
    int limit = 5,
    FeedListType feedListType = FeedListType.local,
    PostSortType postSortType = PostSortType.active,
  }) async {
    return _api.getCommunities(
      page: page,
      limit: limit,
      feedListType: feedListType,
      postSortType: postSortType,
    );
  }
}
