import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/core/enums/feed_list_type.dart';
import 'package:thunder/src/core/enums/post_sort_type.dart';

//// Interface for an account repository
abstract class AccountRepository {
  /// Login to the Lemmy instance.
  Future<String?> login({required String username, required String password, String? totp});

  /// Fetches the user's subscribed communities.
  Future<List<ThunderCommunity>> subscriptions();

  /// Fetches the user's media.
  Future<Map<String, dynamic>> media({int? page, int? limit});

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
}
