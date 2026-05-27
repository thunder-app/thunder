import 'package:thunder/src/foundation/primitives/models/thunder_site.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_my_user.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_language.dart';
import 'package:thunder/src/foundation/primitives/models/thunder_tagline.dart';

class ThunderSiteResponse {
  /// The site view containing site information.
  final ThunderSite site;

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

  ThunderSiteResponse({
    required this.site,
    required this.version,
    this.myUser,
    this.allLanguages,
    this.discussionLanguages,
    this.taglines,
  });

  ThunderSiteResponse copyWith({
    ThunderSite? siteView,
    String? version,
    ThunderMyUser? myUser,
    List<ThunderLanguage>? allLanguages,
    List<int>? discussionLanguages,
    List<ThunderTagline>? taglines,
  }) {
    return ThunderSiteResponse(
      site: siteView ?? site,
      version: version ?? this.version,
      myUser: myUser ?? this.myUser,
      allLanguages: allLanguages ?? this.allLanguages,
      discussionLanguages: discussionLanguages ?? this.discussionLanguages,
      taglines: taglines ?? this.taglines,
    );
  }

  factory ThunderSiteResponse.fromLemmySiteResponse(Map<String, dynamic> response) {
    final myUser = response['my_user'];
    final allLanguages = response['all_languages'];
    final discussionLanguages = response['discussion_languages'];
    final taglines = response['taglines'];

    return ThunderSiteResponse(
      site: ThunderSite.fromLemmySiteView(response['site_view']),
      version: response['version'],
      myUser: myUser != null ? ThunderMyUser.fromLemmyV3MyUser(myUser) : null,
      allLanguages: allLanguages.map<ThunderLanguage>((l) => ThunderLanguage.fromLemmyLanguage(l)).toList(),
      discussionLanguages: discussionLanguages.cast<int>(),
      taglines: taglines.map<ThunderTagline>((t) => ThunderTagline.fromLemmyTagline(t)).toList(),
    );
  }

  factory ThunderSiteResponse.fromPiefedSiteResponse(Map<String, dynamic> response) {
    final site = response['site'];
    final myUser = response['my_user'];
    final allLanguages = site?['all_languages'];
    final discussionLanguages = myUser?['discussion_languages'];

    return ThunderSiteResponse(
      site: ThunderSite.fromPiefedSite(site),
      version: response['version'],
      myUser: myUser != null ? ThunderMyUser.fromPiefedMyUser(myUser) : null,
      allLanguages: allLanguages.map<ThunderLanguage>((l) => ThunderLanguage.fromPiefedLanguage(l)).toList(),
      discussionLanguages: discussionLanguages?.map<int>((language) => language['id'] as int).toList(),
      // taglines: taglines.map<ThunderTagline>((t) => ThunderTagline.fromPiefedTagline(t)).toList(),
    );
  }

  factory ThunderSiteResponse.fromLemmyV4SiteAndAccount({
    required Map<String, dynamic> siteResponse,
    Map<String, dynamic>? accountResponse,
  }) {
    final allLanguages = siteResponse['all_languages'] ?? const [];
    final discussionLanguages = siteResponse['discussion_languages'] ?? const [];
    final taglines = siteResponse['taglines'] ?? const [];

    return ThunderSiteResponse(
      site: ThunderSite.fromLemmyV4SiteView(siteResponse['site_view']),
      version: siteResponse['version'],
      myUser: accountResponse != null ? ThunderMyUser.fromLemmyV4MyUser(accountResponse) : null,
      allLanguages: allLanguages.map<ThunderLanguage>((l) => ThunderLanguage.fromLemmyLanguage(l)).toList(),
      discussionLanguages: discussionLanguages.cast<int>(),
      taglines: taglines.map<ThunderTagline>((t) => ThunderTagline.fromLemmyTagline(t)).toList(),
    );
  }
}
