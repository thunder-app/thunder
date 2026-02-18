import 'package:thunder/src/foundation/primitives/models/version.dart';
import 'package:thunder/src/foundation/utils/check_github_update.dart' as update_checker;

abstract class VersionChecker {
  Future<Version> fetchLatestVersion();
}

class GithubVersionChecker implements VersionChecker {
  const GithubVersionChecker();

  @override
  Future<Version> fetchLatestVersion() {
    return update_checker.fetchVersion();
  }
}
