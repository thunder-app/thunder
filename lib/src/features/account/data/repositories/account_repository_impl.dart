import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/core/network/piefed_api.dart';
import 'package:thunder/src/core/enums/feed_list_type.dart';
import 'package:thunder/src/core/enums/post_sort_type.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/core/enums/threadiverse_platform.dart';
import 'package:thunder/src/core/models/models.dart';
import 'package:thunder/src/app/utils/global_context.dart';

/// Implementation of [AccountRepository]
class AccountRepositoryImpl implements AccountRepository {
  /// The account to use for methods invoked in this repository
  Account account;

  /// The Lemmy client to use for the repository
  late LemmyApiV3 client;

  /// The Piefed client to use for the repository
  late PiefedApi piefed;

  AccountRepositoryImpl({required this.account}) {
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
  Future<String?> login({required String username, required String password, String? totp}) async {
    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await client.run(Login(usernameOrEmail: username, password: password, totp2faToken: totp));
        return response.jwt;
      case ThreadiversePlatform.piefed:
        Map<String, dynamic> body = {
          'username': username,
          'password': password,
        };

        Map<String, String> headers = {
          'Content-Type': 'application/json',
        };

        final uri = Uri.https(account.instance, '/api/alpha/user/login');
        final response = await http.post(uri, body: jsonEncode(body), headers: headers);
        final json = jsonDecode(response.body);
        return json['jwt'];

      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<List<ThunderCommunity>> subscriptions() async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        final response = await client.run(GetSite(auth: account.jwt));
        return response.myUser?.follows.map((cfv) => ThunderCommunity.fromLemmyCommunity(cfv.community.toJson())).toList() ?? [];
      case ThreadiversePlatform.piefed:
        final uri = Uri.https(account.instance, '/api/alpha/site');
        final headers = {if (account.jwt != null) 'Authorization': 'Bearer ${account.jwt}'};

        final response = await http.get(uri, headers: headers);

        final json = jsonDecode(response.body);
        final site = ThunderSiteResponse.fromPiefedSiteResponse(json);
        return site.myUser?.follows ?? [];
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<ListMediaResponse> media({int? page, int? limit}) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await client.run(ListMedia(auth: account.jwt, page: page, limit: limit));
      case ThreadiversePlatform.piefed:
        // TODO: Implement action on Piefed once available
        throw Exception('This feature is not yet available');
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
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
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
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
      case ThreadiversePlatform.piefed:
        await piefed.saveUserSettings(
          bio: bio,
          showNsfw: showNsfw,
          showReadPosts: showReadPosts,
        );
        return SaveUserSettingsResponse(success: true);
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<SuccessResponse> importSettings(String settings) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await client.run(ImportSettings(auth: account.jwt, data: settings));
      case ThreadiversePlatform.piefed:
        // TODO: Implement action on Piefed once available
        throw Exception('This feature is not yet available');
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<dynamic> exportSettings() async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await client.run(ExportSettings(auth: account.jwt));
      case ThreadiversePlatform.piefed:
        // TODO: Implement action on Piefed once available
        throw Exception('This feature is not yet available');
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }
}
