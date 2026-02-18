import 'package:collection/collection.dart';

import 'package:thunder/src/foundation/primitives/enums/post_sort_type.dart';
import 'package:thunder/src/foundation/primitives/enums/feed_list_type.dart';

class ThunderLocalUser {
  /// The local user's email.
  final String? email;

  /// Whether to show NSFW content.
  final bool showNsfw;

  /// The local user's default sort type.
  final PostSortType? defaultSortType;

  /// The local user's default listing type.
  final FeedListType? defaultListingType;

  /// Whether to show scores.
  final bool showScores;

  /// Whether to show bot accounts.
  final bool showBotAccounts;

  /// Whether to show read posts.
  final bool showReadPosts;

  ThunderLocalUser({
    this.email,
    required this.showNsfw,
    this.defaultSortType,
    this.defaultListingType,
    required this.showScores,
    required this.showBotAccounts,
    required this.showReadPosts,
  });

  ThunderLocalUser copyWith({
    String? email,
    bool? showNsfw,
    PostSortType? defaultSortType,
    FeedListType? defaultListingType,
    bool? showScores,
    bool? showBotAccounts,
    bool? showReadPosts,
  }) {
    return ThunderLocalUser(
      email: email ?? this.email,
      showNsfw: showNsfw ?? this.showNsfw,
      defaultSortType: defaultSortType ?? this.defaultSortType,
      defaultListingType: defaultListingType ?? this.defaultListingType,
      showScores: showScores ?? this.showScores,
      showBotAccounts: showBotAccounts ?? this.showBotAccounts,
      showReadPosts: showReadPosts ?? this.showReadPosts,
    );
  }

  factory ThunderLocalUser.fromLemmyLocalUser(Map<String, dynamic> localUser) {
    return ThunderLocalUser(
      email: localUser['email'],
      showNsfw: localUser['show_nsfw'],
      defaultSortType: localUser['default_sort_type'] != null ? PostSortType.values.firstWhereOrNull((e) => e.value == localUser['default_sort_type']) : null,
      defaultListingType: localUser['default_listing_type'] != null ? FeedListType.values.firstWhereOrNull((e) => e.value == localUser['default_listing_type']) : null,
      showScores: localUser['show_scores'],
      showBotAccounts: localUser['show_bot_accounts'],
      showReadPosts: localUser['show_read_posts'],
    );
  }

  factory ThunderLocalUser.fromPiefedLocalUser(Map<String, dynamic> localUser) {
    return ThunderLocalUser(
      // email:localUser['email'],
      showNsfw: localUser['show_nsfw'],
      defaultSortType: localUser['default_sort_type'] != null ? PostSortType.values.firstWhereOrNull((e) => e.value == localUser['default_sort_type']) : null,
      defaultListingType: localUser['default_listing_type'] != null ? FeedListType.values.firstWhereOrNull((e) => e.value == localUser['default_listing_type']) : null,
      showScores: localUser['show_scores'],
      showBotAccounts: localUser['show_bot_accounts'],
      showReadPosts: localUser['show_read_posts'],
    );
  }
}
