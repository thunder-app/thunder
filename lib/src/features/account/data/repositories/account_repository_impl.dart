import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:thunder/src/app/utils/global_context.dart';
import 'package:thunder/src/core/enums/feed_list_type.dart';
import 'package:thunder/src/core/enums/post_sort_type.dart';
import 'package:thunder/src/core/network/api_client_factory.dart';
import 'package:thunder/src/core/network/api_exception.dart';
import 'package:thunder/src/core/network/thunder_api_client.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/community/community.dart';

/// Implementation of [AccountRepository]
class AccountRepositoryImpl implements AccountRepository {
  /// The account to use for methods invoked in this repository
  final Account account;

  /// The API client to use for the repository
  final ThunderApiClient _api;

  /// Creates a new AccountRepositoryImpl.
  ///
  /// An optional [api] client can be provided for testing.
  AccountRepositoryImpl({required this.account, ThunderApiClient? api}) : _api = api ?? ApiClientFactory.create(account, debug: kDebugMode);

  @override
  Future<String?> login({required String username, required String password, String? totp}) async {
    return await _api.login(username: username, password: password, totp: totp);
  }

  @override
  Future<List<ThunderCommunity>> subscriptions() async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final response = await _api.site();
    return response.myUser?.follows ?? [];
  }

  @override
  Future<Map<String, dynamic>> media({int? page, int? limit}) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    if (!_api.supportsMedia) {
      throw UnsupportedFeatureException('Media management', platformName: _api.platformName);
    }

    return await _api.media(page: page, limit: limit);
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

    await _api.saveUserSettings(
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
  }

  @override
  Future<bool> importSettings(String settings) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    if (!_api.supportsSettingsImportExport) {
      throw UnsupportedFeatureException('Settings import', platformName: _api.platformName);
    }

    return await _api.importSettings(settings);
  }

  @override
  Future<dynamic> exportSettings() async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    if (!_api.supportsSettingsImportExport) {
      throw UnsupportedFeatureException('Settings export', platformName: _api.platformName);
    }

    return await _api.exportSettings();
  }

  @override
  Future<String> uploadImage(String filePath) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final response = await _api.uploadImage(filePath);

    if (response['url'] is String && (response['url'] as String).isNotEmpty) {
      return response['url'] as String;
    }

    if (response['files'] != null && (response['files'] as List).isNotEmpty) {
      final filename = response['files'][0]['file'];
      return "https://${account.instance}/pictrs/image/$filename";
    }

    throw ApiErrorException(
      'Failed to upload image: Invalid response $response',
      platformName: _api.platformName,
    );
  }

  @override
  Future<void> deleteImage({required String file, required String token}) async {
    final l10n = GlobalContext.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    if (!_api.supportsMedia) {
      throw UnsupportedFeatureException('Media management');
    }

    await _api.deleteImage(file: file, token: token);
  }
}
