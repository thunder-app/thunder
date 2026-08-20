class ThunderSite {
  /// The site's name.
  final String name;

  /// The site's sidebar.
  final String? sidebar;

  /// The site's icon.
  final String? icon;

  /// The site's description.
  final String? description;

  /// The site's actor ID.
  final String actorId;

  /// The site's content warning.
  final String? contentWarning;

  /// Whether the site allows downvotes.
  final bool? enableDownvotes;

  /// The site's number of users.
  final int? users;

  ThunderSite({required this.name, this.sidebar, this.icon, this.description, required this.actorId, this.contentWarning, this.enableDownvotes, this.users});

  factory ThunderSite.fromLemmySite(Map<String, dynamic> site) {
    return ThunderSite(name: site['name'], sidebar: site['sidebar'], icon: site['icon'], description: site['description'], actorId: site['actor_id'], contentWarning: site['content_warning']);
  }

  factory ThunderSite.fromLemmyV4Site(Map<String, dynamic> site) {
    return ThunderSite(
      name: site['name'],
      sidebar: site['sidebar'],
      icon: site['icon'],
      description: site['description'] ?? site['summary'],
      actorId: site['ap_id'],
      contentWarning: site['content_warning'],
    );
  }

  factory ThunderSite.fromLemmySiteView(Map<String, dynamic> siteView) {
    final site = siteView['site'];
    final localSite = siteView['local_site'];
    final counts = siteView['counts'];

    return ThunderSite(
      name: site['name'],
      sidebar: site['sidebar'],
      icon: site['icon'],
      description: site['description'],
      actorId: site['actor_id'],
      contentWarning: site['content_warning'],
      enableDownvotes: localSite['enable_downvotes'],
      users: counts['users'],
    );
  }

  factory ThunderSite.fromLemmyV4SiteView(Map<String, dynamic> siteView) {
    final site = siteView['site'];
    final localSite = siteView['local_site'];
    final instance = siteView['instance'];

    return ThunderSite(
      name: site['name'],
      sidebar: site['sidebar'],
      icon: site['icon'],
      description: site['description'],
      actorId: instance?['domain'] != null ? 'https://${instance['domain']}' : site['ap_id'],
      contentWarning: site['content_warning'],
      enableDownvotes: localSite?['enable_downvotes'],
      users: instance?['users'],
    );
  }

  factory ThunderSite.fromPiefedSite(Map<String, dynamic> site) {
    return ThunderSite(
      name: site['name'],
      sidebar: site['sidebar_md'] ?? site['sidebar'],
      icon: site['icon'],
      description: site['description'],
      actorId: site['actor_id'],
      // contentWarning: site['content_warning'],
      enableDownvotes: site['enable_downvotes'],
      users: site['user_count'],
    );
  }
}
