import 'package:thunder/core/models/thunder_site.dart';
import 'package:thunder/user/models/thunder_user.dart';
import 'package:thunder/core/models/thunder_my_user.dart';
import 'package:thunder/core/models/thunder_language.dart';
import 'package:thunder/core/models/thunder_tagline.dart';
import 'package:thunder/core/models/thunder_custom_emoji.dart';
import 'package:thunder/core/models/thunder_blocked_url.dart';

class ThunderSiteResponse {
  /// The site view containing site information.
  final ThunderSite site;

  /// List of site administrators.
  final List<ThunderUser> admins;

  /// The Lemmy version of the site.
  final String version;

  /// The current user's detailed information (if authenticated).
  final ThunderMyUser? myUser;

  /// All available languages on the site.
  final List<ThunderLanguage>? allLanguages;

  /// Discussion languages available on the site.
  final List<int>? discussionLanguages;

  /// Site taglines.
  final List<ThunderTagline>? taglines;

  /// Custom emojis available on the site.
  final List<ThunderCustomEmoji>? customEmojis;

  /// URLs blocked by the site.
  final List<ThunderBlockedUrl>? blockedUrls;

  ThunderSiteResponse({
    required this.site,
    required this.admins,
    required this.version,
    this.myUser,
    this.allLanguages,
    this.discussionLanguages,
    this.taglines,
    this.customEmojis,
    this.blockedUrls,
  });

  ThunderSiteResponse copyWith({
    ThunderSite? siteView,
    List<ThunderUser>? admins,
    String? version,
    ThunderMyUser? myUser,
    List<ThunderLanguage>? allLanguages,
    List<int>? discussionLanguages,
    List<ThunderTagline>? taglines,
    List<ThunderCustomEmoji>? customEmojis,
    List<ThunderBlockedUrl>? blockedUrls,
  }) {
    return ThunderSiteResponse(
      site: siteView ?? site,
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
    final myUser = response['my_user'];
    final admins = response['admins'];
    final allLanguages = response['all_languages'];
    final discussionLanguages = response['discussion_languages'];
    final taglines = response['taglines'];
    final customEmojis = response['custom_emojis'];
    final blockedUrls = response['blocked_urls'];

    return ThunderSiteResponse(
      site: ThunderSite.fromLemmySiteView(response['site_view']),
      admins: admins.map<ThunderUser>((admin) => ThunderUser.fromLemmyUser(admin['person'])).toList(),
      version: response['version'],
      myUser: myUser != null ? ThunderMyUser.fromLemmyMyUser(myUser) : null,
      allLanguages: allLanguages.map<ThunderLanguage>((l) => ThunderLanguage.fromLemmyLanguage(l)).toList(),
      discussionLanguages: discussionLanguages.cast<int>(),
      taglines: taglines.map<ThunderTagline>((t) => ThunderTagline.fromLemmyTagline(t)).toList(),
      customEmojis: customEmojis.map<ThunderCustomEmoji>((e) => ThunderCustomEmoji.fromLemmyCustomEmoji(e)).toList(),
      blockedUrls: blockedUrls.map<ThunderBlockedUrl>((b) => ThunderBlockedUrl.fromLemmyBlockedUrl(b)).toList(),
    );
  }

  factory ThunderSiteResponse.fromPiefedSiteResponse(Map<String, dynamic> response) {
    final myUser = response['my_user'];
    final discussionLanguages = myUser != null ? myUser['discussion_languages'] : null;
    final site = response['site'];
    final admins = response['admins'];

    return ThunderSiteResponse(
      site: ThunderSite.fromPiefedSite(site),
      admins: admins.map<ThunderUser>((a) => ThunderUser.fromPiefedUser(a['person'])).toList(),
      version: response['version'],
      myUser: myUser != null ? ThunderMyUser.fromPiefedMyUser(myUser) : null,
      // allLanguages // Not available in PieFed
      discussionLanguages: discussionLanguages?.cast<int>(),
      // taglines // Not available in PieFed
      // customEmojis // Not available in PieFed
      // blockedUrls // Not available in PieFed
    );
  }
}
