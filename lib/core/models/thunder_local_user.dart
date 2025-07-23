import 'package:collection/collection.dart';

import 'package:thunder/core/enums/post_sort_type.dart';
import 'package:thunder/core/enums/feed_list_type.dart';
import 'package:thunder/user/models/thunder_user.dart';

class ThunderLocalUserVoteDisplayMode {
  /// The local user ID this vote display mode belongs to.
  final int localUserId;

  /// Whether to show the score.
  final bool score;

  /// Whether to show upvotes.
  final bool upvotes;

  /// Whether to show downvotes.
  final bool downvotes;

  /// Whether to show upvote percentage.
  final bool upvotePercentage;

  ThunderLocalUserVoteDisplayMode({
    required this.localUserId,
    required this.score,
    required this.upvotes,
    required this.downvotes,
    required this.upvotePercentage,
  });

  factory ThunderLocalUserVoteDisplayMode.fromLemmyVoteDisplayMode(Map<String, dynamic> voteDisplayMode) {
    return ThunderLocalUserVoteDisplayMode(
      localUserId: voteDisplayMode['local_user_id'],
      score: voteDisplayMode['score'],
      upvotes: voteDisplayMode['upvotes'],
      downvotes: voteDisplayMode['downvotes'],
      upvotePercentage: voteDisplayMode['upvote_percentage'],
    );
  }
}

class ThunderLocalUser {
  /// The local user's ID.
  final int? id;

  /// The local user's person ID.
  final int personId;

  /// The local user's email.
  final String? email;

  /// Whether to show NSFW content.
  final bool showNsfw;

  /// The local user's theme.
  final String? theme;

  /// The local user's default sort type.
  final PostSortType? defaultSortType;

  /// The local user's default listing type.
  final FeedListType? defaultListingType;

  /// The local user's interface language.
  final String? interfaceLanguage;

  /// Whether to show avatars.
  final bool? showAvatars;

  /// Whether to send notifications to email.
  final bool? sendNotificationsToEmail;

  /// Whether to show scores.
  final bool showScores;

  /// Whether to show bot accounts.
  final bool showBotAccounts;

  /// Whether to show read posts.
  final bool showReadPosts;

  /// Whether email is verified.
  final bool? emailVerified;

  /// Whether application is accepted.
  final bool? acceptedApplication;

  /// Whether to open links in new tab.
  final bool? openLinksInNewTab;

  /// Whether to blur NSFW content.
  final bool? blurNsfw;

  /// Whether to auto expand content.
  final bool? autoExpand;

  /// Whether infinite scroll is enabled.
  final bool? infiniteScrollEnabled;

  /// Whether the user is an admin.
  final bool admin;

  /// The local user's post listing mode.
  final String? postListingMode;

  /// Whether TOTP 2FA is enabled.
  final bool? totp2faEnabled;

  /// Whether keyboard navigation is enabled.
  final bool? enableKeyboardNavigation;

  /// Whether animated images are enabled.
  final bool? enableAnimatedImages;

  /// Whether to collapse bot comments.
  final bool? collapseBotComments;

  /// The last donation notification date.
  final DateTime? lastDonationNotification;

  ThunderLocalUser({
    this.id,
    required this.personId,
    this.email,
    required this.showNsfw,
    this.theme,
    this.defaultSortType,
    this.defaultListingType,
    this.interfaceLanguage,
    this.showAvatars,
    this.sendNotificationsToEmail,
    required this.showScores,
    required this.showBotAccounts,
    required this.showReadPosts,
    this.emailVerified,
    this.acceptedApplication,
    this.openLinksInNewTab,
    this.blurNsfw,
    this.autoExpand,
    this.infiniteScrollEnabled,
    required this.admin,
    this.postListingMode,
    this.totp2faEnabled,
    this.enableKeyboardNavigation,
    this.enableAnimatedImages,
    this.collapseBotComments,
    this.lastDonationNotification,
  });

  ThunderLocalUser copyWith({
    int? id,
    int? personId,
    String? email,
    bool? showNsfw,
    String? theme,
    PostSortType? defaultSortType,
    FeedListType? defaultListingType,
    String? interfaceLanguage,
    bool? showAvatars,
    bool? sendNotificationsToEmail,
    bool? showScores,
    bool? showBotAccounts,
    bool? showReadPosts,
    bool? emailVerified,
    bool? acceptedApplication,
    bool? openLinksInNewTab,
    bool? blurNsfw,
    bool? autoExpand,
    bool? infiniteScrollEnabled,
    bool? admin,
    String? postListingMode,
    bool? totp2faEnabled,
    bool? enableKeyboardNavigation,
    bool? enableAnimatedImages,
    bool? collapseBotComments,
    DateTime? lastDonationNotification,
  }) {
    return ThunderLocalUser(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      email: email ?? this.email,
      showNsfw: showNsfw ?? this.showNsfw,
      theme: theme ?? this.theme,
      defaultSortType: defaultSortType ?? this.defaultSortType,
      defaultListingType: defaultListingType ?? this.defaultListingType,
      interfaceLanguage: interfaceLanguage ?? this.interfaceLanguage,
      showAvatars: showAvatars ?? this.showAvatars,
      sendNotificationsToEmail: sendNotificationsToEmail ?? this.sendNotificationsToEmail,
      showScores: showScores ?? this.showScores,
      showBotAccounts: showBotAccounts ?? this.showBotAccounts,
      showReadPosts: showReadPosts ?? this.showReadPosts,
      emailVerified: emailVerified ?? this.emailVerified,
      acceptedApplication: acceptedApplication ?? this.acceptedApplication,
      openLinksInNewTab: openLinksInNewTab ?? this.openLinksInNewTab,
      blurNsfw: blurNsfw ?? this.blurNsfw,
      autoExpand: autoExpand ?? this.autoExpand,
      infiniteScrollEnabled: infiniteScrollEnabled ?? this.infiniteScrollEnabled,
      admin: admin ?? this.admin,
      postListingMode: postListingMode ?? this.postListingMode,
      totp2faEnabled: totp2faEnabled ?? this.totp2faEnabled,
      enableKeyboardNavigation: enableKeyboardNavigation ?? this.enableKeyboardNavigation,
      enableAnimatedImages: enableAnimatedImages ?? this.enableAnimatedImages,
      collapseBotComments: collapseBotComments ?? this.collapseBotComments,
      lastDonationNotification: lastDonationNotification ?? this.lastDonationNotification,
    );
  }

  factory ThunderLocalUser.fromLemmyLocalUser(Map<String, dynamic> localUser) {
    return ThunderLocalUser(
      id: localUser['id'],
      personId: localUser['person_id'],
      email: localUser['email'],
      showNsfw: localUser['show_nsfw'],
      theme: localUser['theme'],
      defaultSortType: localUser['default_sort_type'] != null ? PostSortType.values.firstWhereOrNull((e) => e.value == localUser['default_sort_type']) : null,
      defaultListingType: localUser['default_listing_type'] != null ? FeedListType.values.firstWhereOrNull((e) => e.value == localUser['default_listing_type']) : null,
      interfaceLanguage: localUser['interface_language'],
      showAvatars: localUser['show_avatars'],
      sendNotificationsToEmail: localUser['send_notifications_to_email'],
      showScores: localUser['show_scores'],
      showBotAccounts: localUser['show_bot_accounts'],
      showReadPosts: localUser['show_read_posts'],
      emailVerified: localUser['email_verified'],
      acceptedApplication: localUser['accepted_application'],
      openLinksInNewTab: localUser['open_links_in_new_tab'],
      blurNsfw: localUser['blur_nsfw'] ?? true,
      autoExpand: localUser['auto_expand'],
      infiniteScrollEnabled: localUser['infinite_scroll_enabled'],
      admin: localUser['admin'],
      postListingMode: localUser['post_listing_mode'],
      totp2faEnabled: localUser['totp_2fa_enabled'],
      enableKeyboardNavigation: localUser['enable_keyboard_navigation'],
      enableAnimatedImages: localUser['enable_animated_images'],
      collapseBotComments: localUser['collapse_bot_comments'],
      lastDonationNotification: localUser['last_donation_notification'] != null ? DateTime.parse(localUser['last_donation_notification']) : null,
    );
  }

  factory ThunderLocalUser.fromPiefedLocalUser(Map<String, dynamic> localUser, ThunderUser user) {
    return ThunderLocalUser(
      // id // Not available in PieFed
      personId: user.id,
      // email // Not available in PieFed
      showNsfw: localUser['show_nsfw'],
      // theme // Not available in PieFed
      defaultSortType: localUser['default_sort_type'] != null ? PostSortType.values.firstWhereOrNull((e) => e.value == localUser['default_sort_type']) : null,
      defaultListingType: localUser['default_listing_type'] != null ? FeedListType.values.firstWhereOrNull((e) => e.value == localUser['default_listing_type']) : null,
      // interfaceLanguage // Not available in PieFed
      // showAvatars // Not available in PieFed
      // sendNotificationsToEmail // Not available in PieFed
      showScores: localUser['show_scores'],
      showBotAccounts: localUser['show_bot_accounts'],
      showReadPosts: localUser['show_read_posts'],
      // emailVerified // Not available in PieFed
      // acceptedApplication // Not available in PieFed
      // openLinksInNewTab // Not available in PieFed
      blurNsfw: true, // Not available in PieFed
      // autoExpand // Not available in PieFed
      // infiniteScrollEnabled // Not available in PieFed
      admin: user.isAdmin ?? false,
      // postListingMode // Not available in PieFed
      // totp2faEnabled // Not available in PieFed
      // enableKeyboardNavigation // Not available in PieFed
      // enableAnimatedImages // Not available in PieFed
      // collapseBotComments // Not available in PieFed
      // lastDonationNotification // Not available in PieFed
    );
  }
}
