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

  bool supportsFeature(LemmyFeature feature) {
    if (!_lemmySites.containsKey(instance.lemmyApiV3.host)) return false;

    // Parse the version
    GetSiteResponse site = _lemmySites[instance.lemmyApiV3.host]!;
    Version instanceVersion;
    try {
      instanceVersion = Version.parse(site.version);
    } catch (e) {
      return false;
    }

    // Check the feature and return whether it's supported in this version
    return instanceVersion > feature.minSupportedVersion;
  }

  static final Map<String, GetSiteResponse> _lemmySites = <String, GetSiteResponse>{};
}

enum LemmyFeature {
  sortTypeControversial(0, 19, 0, preRelease: ["rc", "1"]),
  sortTypeScaled(0, 19, 0, preRelease: ["rc", "1"]),
  commentSortTypeControversial(0, 19, 0, preRelease: ["rc", "1"]),
  blockInstance(0, 19, 0, preRelease: ["rc", "1"]);

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

enum IncludeVersionSpecificFeature {
  never,
  ifSupported,
  always,
}
