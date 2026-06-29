import 'package:thunder/src/foundation/foundation.dart';
import 'package:thunder/src/foundation/networking/resolved_api_client.dart';
import 'package:thunder/src/features/account/domain/models/account_media.dart';
import 'package:thunder/src/features/account/domain/models/account_settings_update.dart';

/// Repository contract for account authentication and settings.
abstract class AccountRepository {
  /// Login to the account's home instance.
  Future<String?> login({required String username, required String password, String? totp});

  /// Logout the authenticated account on its home instance.
  Future<void> logout();

  /// Fetches the user's subscribed communities.
  Future<List<ThunderCommunity>> subscriptions();

  /// Fetches the user's media.
  Future<ThunderPage<AccountMediaItem>> media({int? page, int? limit});

  /// Saves the user's settings.
  Future<void> saveSettings(AccountSettingsUpdate update);

  /// Imports the settings to the user's profile.
  Future<bool> importSettings(String settings);

  /// Exports the user's settings.
  Future<dynamic> exportSettings();

  /// Upload an image.
  Future<String> uploadImage(String filePath);

  /// Delete an uploaded image.
  Future<void> deleteImage({required String file, String? token});
}

/// Implementation of [AccountRepository] using the unified API client
class AccountRepositoryImpl implements AccountRepository {
  /// The account to use for methods invoked in this repository
  final Account account;

  /// The API client to use for the repository
  final ResolvedApiClient _api;

  /// The localization service to use for user-facing errors
  final LocalizationService _localization;

  /// Creates a new AccountRepositoryImpl.
  ///
  /// An optional [api] client and [localization] can be provided for testing.
  AccountRepositoryImpl({
    required this.account,
    ThunderApiClient? api,
    LocalizationService localization = const ThunderLocalizationService(),
  })  : _api = ResolvedApiClient(account: account, api: api),
        _localization = localization;

  @override
  Future<String?> login({required String username, required String password, String? totp}) async {
    final api = await _api.get();
    return api.login(username: username, password: password, totp: totp);
  }

  @override
  Future<void> logout() async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    await api.logout();
  }

  @override
  Future<List<ThunderCommunity>> subscriptions() async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    final response = await api.site();
    return response.myUser?.follows ?? [];
  }

  @override
  Future<ThunderPage<AccountMediaItem>> media({int? page, int? limit}) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    return api.media(page: page, limit: limit);
  }

  @override
  Future<void> saveSettings(AccountSettingsUpdate update) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    await api.saveUserSettings(update);
  }

  @override
  Future<bool> importSettings(String settings) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    if (!api.supportsSettingsImportExport) {
      throw UnsupportedFeatureException('Settings import', platformName: api.platformName);
    }

    return api.importSettings(settings);
  }

  @override
  Future<dynamic> exportSettings() async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    if (!api.supportsSettingsImportExport) {
      throw UnsupportedFeatureException('Settings export', platformName: api.platformName);
    }

    return api.exportSettings();
  }

  @override
  Future<String> uploadImage(String filePath) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    return api.uploadImage(filePath);
  }

  @override
  Future<void> deleteImage({required String file, String? token}) async {
    final l10n = _localization.l10n;
    if (account.anonymous) throw NotLoggedInException(l10n.userNotLoggedIn);

    final api = await _api.get();
    await api.deleteImage(file: file, token: token);
  }
}
