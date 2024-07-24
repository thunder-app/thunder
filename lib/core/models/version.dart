class Version {
  final String version;
  final bool hasUpdate;
  final String? latestVersion;
  final String? latestVersionUrl;

  Version(
      {required this.version,
      this.hasUpdate = false,
      this.latestVersion,
      this.latestVersionUrl});
}
