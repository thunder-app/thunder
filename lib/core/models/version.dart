class Version {
  final String version;
  final bool hasUpdate;
  final String? latestVersion;

  Version({required this.version, this.hasUpdate = false, this.latestVersion});
}
