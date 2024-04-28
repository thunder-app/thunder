import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:version/version.dart';

class LemmyClient {
  LemmyApiV3 lemmyApiV3 = const LemmyApiV3('');

  LemmyClient();

  LemmyClient._initialize();

  void changeBaseUrl(String baseUrl) {
    lemmyApiV3 = LemmyApiV3(baseUrl);
    _populateSiteInfo(); // Do NOT await this. Let it populate in the background.
  }

  static final LemmyClient _instance = LemmyClient._initialize();

  static LemmyClient get instance => _instance;

  Future<void> _populateSiteInfo() async {
    if (_lemmySites.containsKey(instance.lemmyApiV3.host)) return;

    // Retrieve the site so we can look up metadata about it later
    Account? account = await fetchActiveProfileAccount();

    _lemmySites[instance.lemmyApiV3.host] = await instance.lemmyApiV3.run(
      GetSite(
        auth: account?.jwt,
      ),
    );
  }

  Version? get version {
    if (!_lemmySites.containsKey(instance.lemmyApiV3.host)) return null;

    // Parse the version
    GetSiteResponse site = _lemmySites[instance.lemmyApiV3.host]!;
    try {
      return Version.parse(site.version);
    } catch (e) {
      return null;
    }
  }

  bool supportsSortType(SortType? sortType) => switch (sortType) {
        SortType.controversial => supportsFeature(LemmyFeature.sortTypeControversial),
        SortType.scaled => supportsFeature(LemmyFeature.sortTypeScaled),
        _ => true,
      };

  bool supportsCommentSortType(CommentSortType commentSortType) => switch (commentSortType) {
        CommentSortType.controversial => supportsFeature(LemmyFeature.commentSortTypeControversial),
        _ => true,
      };

  bool supportsFeature(LemmyFeature feature) {
    if (version == null) return false;

    // Check the feature and return whether it's supported in this version
    return version! >= feature.minSupportedVersion;
  }

  static bool versionSupportsFeature(Version? version, LemmyFeature feature) {
    if (version == null) return false;

    if (version == maxVersion) return true;

    // Check the feature and return whether it's supported in this version
    return version >= feature.minSupportedVersion;
  }

  /// This is a special Version object which simulates a "maximum possible version".
  /// Note that it doesn't actually work as a max version in terms of comparison,
  /// but it can be reference checked.
  static Version maxVersion = Version(0, 0, 0, build: "max-version");

  String generatePostUrl(int id) => 'https://${lemmyApiV3.host}/post/$id';

  String generateCommentUrl(int id) => 'https://${lemmyApiV3.host}/comment/$id';

  String generateCommunityUrl(String community) => 'https://${lemmyApiV3.host}/c/$community';

  String generateUserUrl(String community) => 'https://${lemmyApiV3.host}/u/$community';

  static final Map<String, GetSiteResponse> _lemmySites = <String, GetSiteResponse>{};
}

enum LemmyFeature {
  sortTypeControversial(0, 19, 0, preRelease: ["rc", "1"]),
  sortTypeScaled(0, 19, 0, preRelease: ["rc", "1"]),
  commentSortTypeControversial(0, 19, 0, preRelease: ["rc", "1"]),
  blockInstance(0, 19, 0, preRelease: ["rc", "1"]),
  multiRead(0, 19, 0, preRelease: ["rc", "1"]);

  final int major;
  final int minor;
  final int patch;
  final List<String> preRelease;

  const LemmyFeature(this.major, this.minor, this.patch, {this.preRelease = const []});

  Version get minSupportedVersion => Version(
        major,
        minor,
        patch,
        // The Version package attempts to modify this list, so give them a non-final copy.
        preRelease: List.from(preRelease),
      );
}
