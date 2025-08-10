import 'package:collection/collection.dart';

import 'package:thunder/src/core/enums/enums.dart';
import 'package:thunder/src/core/enums/post_sort_type.dart';

class ThunderSite {
  /// The site's ID.
  final int? id;

  /// The site's name.
  final String name;

  /// The site's sidebar.
  final String? sidebar;

  /// The site's created date.
  final DateTime? published;

  /// The site's updated date.
  final DateTime? updated;

  /// The site's icon.
  final String? icon;

  /// The site's banner.
  final String? banner;

  /// The site's description.
  final String? description;

  /// The site's actor ID.
  final String actorId;

  /// The site's last refreshed at date.
  final DateTime? lastRefreshedAt;

  /// The site's inbox URL.
  final String? inboxUrl;

  /// The site's public key.
  final String? publicKey;

  /// The site's instance ID.
  final int? instanceId;

  /// The site's content warning.
  final String? contentWarning;

  /// Whether the site is setup.
  final bool? siteSetup;

  /// Whether the site allows downvotes.
  final bool? enableDownvotes;

  /// Whether the site allows NSFW content.
  final bool? enableNsfw;

  /// Whether the site requires admin approval for community creation.
  final bool? communityCreationAdminOnly;

  /// Whether the site requires email verification.
  final bool? requireEmailVerification;

  /// The site's application question.
  final String? applicationQuestion;

  /// Whether the site is private.
  final bool? privateInstance;

  /// The site's default theme.
  final String? defaultTheme;

  /// The site's default post listing type.
  final FeedListType? defaultPostListingType;

  /// The site's legal information.
  final String? legalInformation;

  /// Whether the site hides modlog mod names.
  final bool? hideModlogModNames;

  /// Whether admins can receive application emails.
  final bool? applicationEmailAdmins;

  /// The site's slur filter regex.
  final String? slurFilterRegex;

  /// The site's actor name max length.
  final int? actorNameMaxLength;

  /// Whether the site allows federation.
  final bool? federationEnabled;

  /// Whether the site requires captcha.
  final bool? captchaEnabled;

  /// The site's captcha difficulty.
  final String? captchaDifficulty;

  /// The site's registration mode.
  final String? registrationMode;

  /// Whether the site allows reports to be emailed to admins.
  final bool? reportsEmailAdmins;

  /// Whether the site fetches signed federation data.
  final bool? federationSignedFetch;

  /// The site's default post listing mode.
  final String? defaultPostListingMode;

  /// The site's default sort type.
  final PostSortType? defaultSortType;

  /// The site's rate limits.
  final Map<String, dynamic>? localSiteRateLimit;

  /// The site's number of users.
  final int? users;

  /// The site's number of posts.
  final int? posts;

  /// The site's number of comments.
  final int? comments;

  /// The site's number of communities.
  final int? communities;

  /// The site's number of users active in the last day.
  final int? usersActiveDay;

  /// The site's number of users active in the last week.
  final int? usersActiveWeek;

  /// The site's number of users active in the last month.
  final int? usersActiveMonth;

  /// The site's number of users active in the last half year.
  final int? usersActiveHalfYear;

  ThunderSite({
    this.id,
    required this.name,
    this.sidebar,
    this.published,
    this.updated,
    this.icon,
    this.banner,
    this.description,
    required this.actorId,
    this.lastRefreshedAt,
    this.inboxUrl,
    this.publicKey,
    this.instanceId,
    this.contentWarning,
    this.siteSetup,
    this.enableDownvotes,
    this.enableNsfw,
    this.communityCreationAdminOnly,
    this.requireEmailVerification,
    this.applicationQuestion,
    this.privateInstance,
    this.defaultTheme,
    this.defaultPostListingType,
    this.legalInformation,
    this.hideModlogModNames,
    this.applicationEmailAdmins,
    this.slurFilterRegex,
    this.actorNameMaxLength,
    this.federationEnabled,
    this.captchaEnabled,
    this.captchaDifficulty,
    this.registrationMode,
    this.reportsEmailAdmins,
    this.federationSignedFetch,
    this.defaultPostListingMode,
    this.defaultSortType,
    this.localSiteRateLimit,
    this.users,
    this.posts,
    this.comments,
    this.communities,
    this.usersActiveDay,
    this.usersActiveWeek,
    this.usersActiveMonth,
    this.usersActiveHalfYear,
  });

  factory ThunderSite.fromLemmySite(Map<String, dynamic> site) {
    return ThunderSite(
      id: site['id'],
      name: site['name'],
      sidebar: site['sidebar'],
      published: DateTime.parse(site['published']),
      updated: site['updated'] != null ? DateTime.parse(site['updated']) : null,
      icon: site['icon'],
      banner: site['banner'],
      description: site['description'],
      actorId: site['actor_id'],
      lastRefreshedAt: DateTime.parse(site['last_refreshed_at']),
      inboxUrl: site['inbox_url'],
      publicKey: site['public_key'],
      instanceId: site['instance_id'],
      contentWarning: site['content_warning'],
    );
  }

  factory ThunderSite.fromLemmySiteView(Map<String, dynamic> siteView) {
    final site = siteView['site'];
    final localSite = siteView['local_site'];
    final localSiteRateLimit = siteView['local_site_rate_limit'];
    final counts = siteView['counts'];

    return ThunderSite(
      id: site['id'],
      name: site['name'],
      sidebar: site['sidebar'],
      published: DateTime.parse(site['published']),
      updated: site['updated'] != null ? DateTime.parse(site['updated']) : null,
      icon: site['icon'],
      banner: site['banner'],
      description: site['description'],
      actorId: site['actor_id'],
      lastRefreshedAt: DateTime.parse(site['last_refreshed_at']),
      inboxUrl: site['inbox_url'],
      publicKey: site['public_key'],
      instanceId: site['instance_id'],
      contentWarning: site['content_warning'],
      siteSetup: localSite['site_setup'],
      enableDownvotes: localSite['enable_downvotes'],
      enableNsfw: localSite['enable_nsfw'],
      communityCreationAdminOnly: localSite['community_creation_admin_only'],
      requireEmailVerification: localSite['require_email_verification'],
      applicationQuestion: localSite['application_question'],
      privateInstance: localSite['private_instance'],
      defaultTheme: localSite['default_theme'],
      defaultPostListingType: FeedListType.values.firstWhereOrNull((e) => e.value == localSite['default_post_listing_type']),
      legalInformation: localSite['legal_information'],
      hideModlogModNames: localSite['hide_modlog_mod_names'],
      applicationEmailAdmins: localSite['application_email_admins'],
      slurFilterRegex: localSite['slur_filter_regex'],
      actorNameMaxLength: localSite['actor_name_max_length'],
      federationEnabled: localSite['federation_enabled'],
      captchaEnabled: localSite['captcha_enabled'],
      captchaDifficulty: localSite['captcha_difficulty'],
      registrationMode: localSite['registration_mode'],
      reportsEmailAdmins: localSite['reports_email_admins'],
      federationSignedFetch: localSite['federation_signed_fetch'],
      defaultPostListingMode: localSite['default_post_listing_mode'],
      defaultSortType: PostSortType.values.firstWhereOrNull((e) => e.value == localSite['default_sort_type']),
      localSiteRateLimit: localSiteRateLimit,
      users: counts['users'],
      posts: counts['posts'],
      comments: counts['comments'],
      communities: counts['communities'],
      usersActiveDay: counts['users_active_day'],
      usersActiveWeek: counts['users_active_week'],
      usersActiveMonth: counts['users_active_month'],
      usersActiveHalfYear: counts['users_active_half_year'],
    );
  }

  factory ThunderSite.fromPiefedSite(Map<String, dynamic> site) {
    return ThunderSite(
      // id // Not available in PieFed
      name: site['name'],
      sidebar: site['sidebar'],
      // published // Not available in PieFed
      // updated // Not available in PieFed
      icon: site['icon'],
      // banner // Not available in PieFed
      description: site['description'],
      actorId: site['actor_id'],
      // lastRefreshedAt // Not available in PieFed
      // inboxUrl // Not available in PieFed
      // publicKey // Not available in PieFed
      // instanceId // Not available in PieFed
      // contentWarning // Not available in PieFed
      enableDownvotes: site['enable_downvotes'],
      registrationMode: site['registration_mode'],
      users: site['user_count'],
    );
  }
}
