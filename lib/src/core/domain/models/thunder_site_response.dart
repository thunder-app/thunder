import 'package:thunder/src/core/domain/models/thunder_site.dart';
import 'package:thunder/src/core/domain/models/thunder_my_user.dart';
import 'package:thunder/src/core/domain/models/thunder_language.dart';
import 'package:thunder/src/core/domain/models/thunder_tagline.dart';

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

  ThunderSiteResponse({required this.site, required this.version, this.myUser, this.allLanguages, this.discussionLanguages, this.taglines});

  ThunderSiteResponse copyWith({ThunderSite? siteView, String? version, ThunderMyUser? myUser, List<ThunderLanguage>? allLanguages, List<int>? discussionLanguages, List<ThunderTagline>? taglines}) {
    return ThunderSiteResponse(
      site: siteView ?? site,
      version: version ?? this.version,
      myUser: myUser ?? this.myUser,
      allLanguages: allLanguages ?? this.allLanguages,
      discussionLanguages: discussionLanguages ?? this.discussionLanguages,
      taglines: taglines ?? this.taglines,
    );
  }
}
