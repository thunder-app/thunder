import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:thunder/src/foundation/contracts/contracts.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/foundation/networking/networking.dart';
import 'package:thunder/src/foundation/errors/errors.dart';
import 'package:thunder/src/features/account/account.dart';

/// Implementation of [AccountRepository]
class AccountRepositoryImpl implements AccountRepository {
  /// The account to use for methods invoked in this repository
  final Account account;

  /// The API client to use for the repository
  final ThunderApiClient _api;

  /// The localization service to use for user-facing errors
  final LocalizationService _localizationService;

  /// Creates a new AccountRepositoryImpl.
  ///
  /// An optional [api] client can be provided for testing.
  AccountRepositoryImpl({
    required this.account,
    ThunderApiClient? api,
    LocalizationService localizationService = const GlobalContextLocalizationService(),
  })  : _api = api ?? ApiClientFactory.create(account, debug: kDebugMode),
        _localizationService = localizationService;

  @override
  Future<String?> login({required String username, required String password, String? totp}) async {
    return await _api.login(username: username, password: password, totp: totp);
  }

  @override
  Future<List<ThunderCommunity>> subscriptions() async {
    final l10n = _localizationService.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    final response = await _api.site();
    return response.myUser?.follows ?? [];
  }

  @override
  Future<AccountMedia> media({int? page, int? limit}) async {
    final l10n = _localizationService.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    if (!_api.supportsMedia) {
      throw UnsupportedFeatureException('Media management', platformName: _api.platformName);
    }

    final response = await _api.media(page: page, limit: limit);
    final images = (response['images'] as List<dynamic>? ?? []).whereType<Map<String, dynamic>>().toList();
    return AccountMedia(images: images);
  }

  @override
  Future<void> saveSettings(AccountSettingsUpdate update) async {
    final l10n = _localizationService.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    await _api.saveUserSettings(update);
  }

  @override
  Future<bool> importSettings(String settings) async {
    final l10n = _localizationService.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    if (!_api.supportsSettingsImportExport) {
      throw UnsupportedFeatureException('Settings import', platformName: _api.platformName);
    }

    return await _api.importSettings(settings);
  }

  @override
  Future<dynamic> exportSettings() async {
    final l10n = _localizationService.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    if (!_api.supportsSettingsImportExport) {
      throw UnsupportedFeatureException('Settings export', platformName: _api.platformName);
    }

    return await _api.exportSettings();
  }

  @override
  Future<String> uploadImage(String filePath) async {
    final l10n = _localizationService.l10n;
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
    final l10n = _localizationService.l10n;
    if (account.anonymous) throw Exception(l10n.userNotLoggedIn);

    if (!_api.supportsMedia) {
      throw UnsupportedFeatureException('Media management');
    }

    await _api.deleteImage(file: file, token: token);
  }
}
