import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/features/account/domain/models/account_media.dart';

//// Interface for an account repository
abstract class AccountRepository {
  /// Login to the Lemmy instance.
  Future<String?> login({required String username, required String password, String? totp});

  /// Fetches the user's subscribed communities.
  Future<List<ThunderCommunity>> subscriptions();

  /// Fetches the user's media.
  Future<AccountMedia> media({int? page, int? limit});

  /// Saves the user's settings.
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
  });

  /// Imports the settings to the user's profile.
  Future<bool> importSettings(String settings);

  /// Exports the user's settings.
  Future<dynamic> exportSettings();

  /// Upload an image.
  Future<String> uploadImage(String filePath);

  /// Delete an uploaded image.
  Future<void> deleteImage({required String file, required String token});
}
