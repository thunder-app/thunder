import 'package:thunder/core/models/thunder_site.dart';
import 'package:thunder/user/models/thunder_user.dart';
import 'package:thunder/core/models/thunder_my_user.dart';
import 'package:thunder/core/models/thunder_language.dart';
import 'package:thunder/core/models/thunder_tagline.dart';
import 'package:thunder/core/models/thunder_custom_emoji.dart';
import 'package:thunder/core/models/thunder_blocked_url.dart';

class ThunderAdminUser {
  /// The admin user.
  final ThunderUser user;

  /// The admin user's post and comment counts.
  final Map<String, dynamic>? counts;

  /// Whether this user is an admin.
  final bool isAdmin;

  ThunderAdminUser({
    required this.user,
    this.counts,
    required this.isAdmin,
  });

  factory ThunderAdminUser.fromLemmyAdmin(Map<String, dynamic> admin) {
    return ThunderAdminUser(
      user: ThunderUser.fromLemmyUser(admin['person']),
      counts: admin['counts'],
      isAdmin: admin['is_admin'],
    );
  }
}

class ThunderSiteResponse {
  /// The site view containing site information.
  final ThunderSite siteView;

  /// List of site administrators.
  final List<ThunderAdminUser> admins;

  /// The Lemmy version of the site.
  final String version;

  /// The current user's detailed information (if authenticated).
  final ThunderMyUser? myUser;

  /// All available languages on the site.
  final List<ThunderLanguage> allLanguages;

  /// Discussion languages available on the site.
  final List<int> discussionLanguages;

  /// Site taglines.
  final List<ThunderTagline> taglines;

  /// Custom emojis available on the site.
  final List<ThunderCustomEmoji> customEmojis;

  /// URLs blocked by the site.
  final List<ThunderBlockedUrl> blockedUrls;

  ThunderSiteResponse({
    required this.siteView,
    required this.admins,
    required this.version,
    this.myUser,
    required this.allLanguages,
    required this.discussionLanguages,
    required this.taglines,
    required this.customEmojis,
    required this.blockedUrls,
  });

  ThunderSiteResponse copyWith({
    ThunderSite? siteView,
    List<ThunderAdminUser>? admins,
    String? version,
    ThunderMyUser? myUser,
    List<ThunderLanguage>? allLanguages,
    List<int>? discussionLanguages,
    List<ThunderTagline>? taglines,
    List<ThunderCustomEmoji>? customEmojis,
    List<ThunderBlockedUrl>? blockedUrls,
  }) {
    return ThunderSiteResponse(
      siteView: siteView ?? this.siteView,
      admins: admins ?? this.admins,
      version: version ?? this.version,
      myUser: myUser ?? this.myUser,
      allLanguages: allLanguages ?? this.allLanguages,
      discussionLanguages: discussionLanguages ?? this.discussionLanguages,
      taglines: taglines ?? this.taglines,
      customEmojis: customEmojis ?? this.customEmojis,
      blockedUrls: blockedUrls ?? this.blockedUrls,
    );
  }

  factory ThunderSiteResponse.fromLemmySiteResponse(Map<String, dynamic> response) {
    final adminsList = response['admins'] as List<dynamic>? ?? [];
    final allLanguagesList = response['all_languages'] as List<dynamic>? ?? [];
    final discussionLanguagesList = response['discussion_languages'] as List<dynamic>? ?? [];
    final taglinesList = response['taglines'] as List<dynamic>? ?? [];
    final customEmojisList = response['custom_emojis'] as List<dynamic>? ?? [];
    final blockedUrlsList = response['blocked_urls'] as List<dynamic>? ?? [];

    return ThunderSiteResponse(
      siteView: ThunderSite.fromLemmySiteView(response['site_view']),
      admins: adminsList.map((a) => ThunderAdminUser.fromLemmyAdmin(a)).toList(),
      version: response['version'],
      myUser: response['my_user'] != null ? ThunderMyUser.fromLemmyMyUser(response['my_user']) : null,
      allLanguages: allLanguagesList.map((l) => ThunderLanguage.fromLemmyLanguage(l)).toList(),
      discussionLanguages: discussionLanguagesList.cast<int>(),
      taglines: taglinesList.map((t) => ThunderTagline.fromLemmyTagline(t)).toList(),
      customEmojis: customEmojisList.map((e) => ThunderCustomEmoji.fromLemmyCustomEmoji(e)).toList(),
      blockedUrls: blockedUrlsList.map((b) => ThunderBlockedUrl.fromLemmyBlockedUrl(b)).toList(),
    );
  }
}
