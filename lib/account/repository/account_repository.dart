import 'dart:async';

import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/account/account.dart';
import 'package:thunder/core/enums/feed_list_type.dart';
import 'package:thunder/core/enums/post_sort_type.dart';
import 'package:thunder/core/models/thunder_community.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/utils/global_context.dart';

//// Interface for an account repository
abstract class AccountRepository {
  /// Login to the Lemmy instance.
  Future<LoginResponse> login({required String username, required String password, String? totp});

  Future<List<ThunderCommunity>> subscriptions({int? page, int? limit});

  /// Fetches the user's media.
  Future<ListMediaResponse> media({int? page, int? limit});

  /// Saves the user's settings.
  Future<SaveUserSettingsResponse> saveSettings({
    String? bio,
    String? email,
    String? matrixUserId,
    String? displayName,
    FeedListType? defaultFeedListType,
    PostSortType? defaultPostSortType,
    bool? showNsfw,
    bool? showReadPosts,
    bool? showScores,
    bool? botAccount,
    bool? showBotAccounts,
    List<int>? discussionLanguages,
  });

  /// Imports the settings to the user's profile.
  Future<SuccessResponse> importSettings(String settings);

  /// Exports the user's settings.
  Future<dynamic> exportSettings();

  /// Dispose method to clean up resources
  void dispose();
}

/// Implementation of [AccountRepository] using Lemmy API
class LemmyAccountRepository implements AccountRepository {
  /// The Lemmy client to use for the repository
  LemmyApiV3 client;

  /// Stream subscription for client changes
  StreamSubscription<LemmyApiV3>? _subscription;

  LemmyAccountRepository({required this.client}) {
    _subscription = LemmyClient.onClientChanged.listen((newClient) => client = newClient);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  Future<LoginResponse> login({required String username, required String password, String? totp}) async {
    return client.run(Login(usernameOrEmail: username, password: password, totp2faToken: totp));
  }

  @override
  Future<List<ThunderCommunity>> subscriptions({int? page, int? limit}) async {
    final l10n = GlobalContext.l10n;
    final account = await fetchActiveProfile();
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final response = await client.run(ListCommunities(
      auth: account.jwt,
      page: page,
      limit: 50,
      type: FeedListType.subscribed.toLemmyType(),
    ));

    return response.communities.map((cv) => ThunderCommunity(cv.community, communityView: cv)).toList();
  }

  @override
  Future<ListMediaResponse> media({int? page, int? limit}) async {
    final l10n = GlobalContext.l10n;
    final account = await fetchActiveProfile();
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    return client.run(ListMedia(auth: account.jwt, page: page, limit: limit));
  }

  @override
  Future<SaveUserSettingsResponse> saveSettings({
    String? bio,
    String? email,
    String? matrixUserId,
    String? displayName,
    FeedListType? defaultFeedListType,
    PostSortType? defaultPostSortType,
    bool? showNsfw,
    bool? showReadPosts,
    bool? showScores,
    bool? botAccount,
    bool? showBotAccounts,
    List<int>? discussionLanguages,
  }) async {
    final l10n = GlobalContext.l10n;
    final account = await fetchActiveProfile();
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    return await client.run(SaveUserSettings(
      auth: account.jwt,
      bio: bio,
      email: email,
      matrixUserId: matrixUserId,
      displayName: displayName,
      defaultListingType: defaultFeedListType?.toLemmyType(),
      defaultSortType: defaultPostSortType?.toLemmyType(),
      showNsfw: showNsfw,
      showReadPosts: showReadPosts,
      showScores: showScores,
      botAccount: botAccount,
      showBotAccounts: showBotAccounts,
      discussionLanguages: discussionLanguages,
    ));
  }

  @override
  Future<SuccessResponse> importSettings(String settings) async {
    final l10n = GlobalContext.l10n;
    final account = await fetchActiveProfile();
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    return await client.run(ImportSettings(auth: account.jwt, data: settings));
  }

  @override
  Future<dynamic> exportSettings() async {
    final l10n = GlobalContext.l10n;
    final account = await fetchActiveProfile();
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    return await client.run(ExportSettings(auth: account.jwt));
  }
}
