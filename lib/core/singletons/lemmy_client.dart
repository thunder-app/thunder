import 'package:lemmy_api_client/v3.dart';
import 'package:thunder/account/models/account.dart';
import 'package:thunder/core/auth/helpers/fetch_account.dart';
import 'package:version/version.dart';

class LemmyClient {
  LemmyApiV3 lemmyApiV3 = const LemmyApiV3('');

  LemmyClient._initialize();

  void changeBaseUrl(String baseUrl) {
    lemmyApiV3 = LemmyApiV3(baseUrl);
    _populateSiteInfo(); // Do NOT await this. Let it populate in the background.
  }

  static final LemmyClient _instance = LemmyClient._initialize();

  static LemmyClient get instance => _instance;

  Future<void> _populateSiteInfo() async {
    if (!_lemmySites.containsKey(instance.lemmyApiV3.host)) {
      // Retrieve the site so we can look up metadata about it later
      Account? account = await fetchActiveProfileAccount();

      _lemmySites[instance.lemmyApiV3.host] = await instance.lemmyApiV3.run(
        GetSite(
          auth: account?.jwt,
        ),
      );
    }
  }

  bool supportsFeature(LemmyFeature feature) {
    if (_lemmySites.containsKey(instance.lemmyApiV3.host)) {
      // Parse the version
      FullSiteView site = _lemmySites[instance.lemmyApiV3.host]!;
      Version version;
      try {
        version = Version.parse(site.version);
      } catch (e) {
        return false;
      }

      // Check the feature and return whether it's supported in this version
      return switch (feature) {
        LemmyFeature.sortTypeControversial || LemmyFeature.sortTypeScaled || LemmyFeature.commentSortTypeControversial => version >= Version(0, 19, 0, preRelease: ["rc", "1"]),
      };
    }

    return false;
  }

  static final Map<String, FullSiteView> _lemmySites = <String, FullSiteView>{};
}

enum LemmyFeature {
  sortTypeControversial,
  sortTypeScaled,
  commentSortTypeControversial,
}

enum IncludeVersionSpecificFeature {
  never,
  ifSupported,
  always,
}
