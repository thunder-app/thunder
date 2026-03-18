import 'package:thunder/src/foundation/primitives/primitives.dart';

class AccountSettingsUpdate {
  const AccountSettingsUpdate({
    this.displayName,
    this.bio,
    this.defaultFeedListType,
    this.defaultPostSortType,
    this.showNsfw,
    this.showNsfl,
    this.showReadPosts,
    this.showBotAccounts,
    this.discussionLanguages,
  });

  /// The user's display name.
  final String? displayName;

  /// The user's bio.
  final String? bio;

  /// The user's default feed list type.
  final FeedListType? defaultFeedListType;

  /// The user's default post sort type.
  final PostSortType? defaultPostSortType;

  /// Whether to show NSFW content.
  final bool? showNsfw;

  /// Whether to show NSFL content.
  final bool? showNsfl;

  /// Whether to show read posts.
  final bool? showReadPosts;

  /// Whether to show bot accounts.
  final bool? showBotAccounts;

  /// The user's discussion languages.
  final List<int>? discussionLanguages;
}
