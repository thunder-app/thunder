import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/core/network/lemmy_api.dart';
import 'package:thunder/src/core/network/piefed_api.dart';
import 'package:thunder/src/core/enums/feed_list_type.dart';
import 'package:thunder/src/core/enums/post_sort_type.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/core/enums/threadiverse_platform.dart';
import 'package:thunder/src/app/utils/global_context.dart';

/// Implementation of [AccountRepository]
class AccountRepositoryImpl implements AccountRepository {
  /// The account to use for methods invoked in this repository
  Account account;

  /// The Lemmy client to use for the repository
  late LemmyApi lemmy;

  /// The Piefed client to use for the repository
  late PiefedApi piefed;

  AccountRepositoryImpl({required this.account}) {
    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        lemmy = LemmyApi(account: account, debug: kDebugMode);
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
        return await lemmy.login(username: username, password: password, totp: totp);
      case ThreadiversePlatform.piefed:
        return await piefed.login(username: username, password: password);
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
        final response = await lemmy.site();
        return response.myUser?.follows ?? [];
      case ThreadiversePlatform.piefed:
        final response = await piefed.site();
        return response.myUser?.follows ?? [];
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<Map<String, dynamic>> media({int? page, int? limit}) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await lemmy.media(page: page, limit: limit);
      case ThreadiversePlatform.piefed:
        throw Exception('This feature is not yet available');
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<void> saveSettings({
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
        return await lemmy.saveUserSettings(
          bio: bio,
          email: email,
          matrixUserId: matrixUserId,
          displayName: displayName,
          defaultFeedListType: defaultFeedListType,
          defaultPostSortType: defaultPostSortType,
          showNsfw: showNsfw,
          showReadPosts: showReadPosts,
          showScores: showScores,
          botAccount: botAccount,
          showBotAccounts: showBotAccounts,
          discussionLanguages: discussionLanguages,
        );
      case ThreadiversePlatform.piefed:
        await piefed.saveUserSettings(
          bio: bio,
          showNsfw: showNsfw,
          showReadPosts: showReadPosts,
        );
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }

  @override
  Future<bool> importSettings(String settings) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    switch (account.platform) {
      case ThreadiversePlatform.lemmy:
        return await lemmy.importSettings(settings);
      case ThreadiversePlatform.piefed:
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
        return await lemmy.exportSettings();
      case ThreadiversePlatform.piefed:
        throw Exception('This feature is not yet available');
      default:
        throw Exception('Unsupported platform: ${account.platform}');
    }
  }
}
