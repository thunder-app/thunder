import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:thunder/community/models/thunder_community.dart';
import 'package:thunder/localizations/app_localizations.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/shared/avatars/community_avatar.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/full_name_widgets.dart';
import 'package:thunder/user/models/thunder_user.dart';
import 'package:thunder/user/widgets/user_header/user_header.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/global_context.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/navigation.dart';

/// A widget that displays detailed information about a user.
class UserInformation extends StatefulWidget {
  /// The user to display in the sidebar.
  final ThunderUser user;

  /// The communities that the user moderates.
  final List<ThunderCommunity> moderates;

  const UserInformation({
    super.key,
    required this.user,
    required this.moderates,
  });

  @override
  State<UserInformation> createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserHeader(user: widget.user, moderates: widget.moderates, condensed: true),
          SidebarSectionHeader(value: l10n.profileBio),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CommonMarkdownBody(body: widget.user.bio ?? '_${l10n.noProfileBioSet}_', imageMaxWidth: MediaQuery.of(context).size.width),
          ),
          SidebarSectionHeader(value: l10n.stats),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: UserStatsList(user: widget.user),
          ),
          SidebarSectionHeader(value: l10n.activity),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: UserActivityList(user: widget.user),
          ),
          if (widget.moderates.isNotEmpty) ...[
            SidebarSectionHeader(value: l10n.moderates),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: UserModeratorList(moderates: widget.moderates),
            ),
          ],
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 32.0),
        ],
      ),
    );
  }
}

/// A widget that displays a list of user statistics.
class UserStatsList extends StatelessWidget {
  /// The user to display the stats for.
  final ThunderUser user;

  const UserStatsList({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SidebarStat(
          icon: Icons.cake_rounded,
          value: '${l10n.joined(DateFormat.yMMMMd().format(user.published))} · ${l10n.ago(formatTimeToString(dateTime: user.published.toIso8601String()))}',
        ),
        const SizedBox(height: 8.0),
        SidebarStat(
          icon: Icons.wysiwyg_rounded,
          value: l10n.totalPosts(NumberFormat("#,###,###,###").format(user.posts)),
        ),
        SidebarStat(
          icon: Icons.chat_rounded,
          value: l10n.totalComments(NumberFormat("#,###,###,###").format(user.comments)),
        ),
      ],
    );
  }
}

/// A widget that displays a list of user activity metrics.
class UserActivityList extends StatelessWidget {
  /// The user to display the activity for.
  final ThunderUser user;

  const UserActivityList({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final accountAge = DateTime.now().difference(user.published);
    final accountAgeMonths = ((accountAge.inDays) / 30).toDouble();

    final totalContributions = ((user.posts ?? 0) + (user.comments ?? 0));
    final totalContributionsPerMonth = (totalContributions / (accountAgeMonths < 1 ? 1 : accountAgeMonths));

    int postsPerMonth;
    int commentsPerMonth;

    if (user.posts != null && user.posts != 0) {
      postsPerMonth = (user.posts! / (accountAgeMonths < 1 ? 1 : accountAgeMonths)).truncate();
    } else {
      postsPerMonth = 0;
    }

    if (user.comments != null && user.comments != 0) {
      commentsPerMonth = (user.comments! / (accountAgeMonths < 1 ? 1 : accountAgeMonths)).truncate();
    } else {
      commentsPerMonth = 0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SidebarStat(
          icon: Icons.wysiwyg_rounded,
          value: l10n.averagePosts(NumberFormat("#,###,###,###").format(postsPerMonth)),
        ),
        SidebarStat(
          icon: Icons.chat_rounded,
          value: l10n.averageComments(NumberFormat("#,###,###,###").format(commentsPerMonth)),
        ),
        SidebarStat(
          icon: Icons.score_rounded,
          value: l10n.averageContributions(NumberFormat("#,###,###,###").format(totalContributionsPerMonth)),
        ),
      ],
    );
  }
}

/// A widget that displays a list of communities moderated by a user.
class UserModeratorList extends StatelessWidget {
  /// The communities that the user moderates.
  final List<ThunderCommunity> moderates;

  const UserModeratorList({super.key, required this.moderates});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final community in moderates)
          InkWell(
            onTap: () => navigateToFeedPage(context, feedType: FeedType.community, communityId: community.id),
            borderRadius: BorderRadius.circular(50),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                spacing: 16.0,
                children: [
                  CommunityAvatar(community: community, radius: 20.0),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.55,
                        child: Text(
                          community.title,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                        ),
                      ),
                      CommunityFullNameWidget(
                        context,
                        community.name,
                        community.title,
                        fetchInstanceNameFromUrl(community.actorId),
                        textStyle: const TextStyle(fontSize: 13.0),
                        transformColor: (color) => color?.withValues(alpha: 0.6),
                        useDisplayName: false, // Override because we're showing display name above
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// A widget that displays a section header in the sidebar.
class SidebarSectionHeader extends StatelessWidget {
  /// The header title.
  final String value;

  const SidebarSectionHeader({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 8.0, left: 8.0, right: 8.0),
      child: Row(
        children: [
          Text(value),
          const Expanded(child: Divider(height: 5.0, thickness: 2.0, indent: 15.0)),
        ],
      ),
    );
  }
}

/// A widget that displays a statistic in the sidebar.
class SidebarStat extends StatelessWidget {
  /// The icon to display for the statistic.
  final IconData icon;

  /// The value of the statistic.
  final String value;

  const SidebarStat({super.key, required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0, top: 2.0, bottom: 2.0),
          child: Icon(
            icon,
            size: 18.0,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
        Text(
          value,
          style: TextStyle(color: theme.textTheme.titleSmall?.color?.withValues(alpha: 0.65)),
        ),
      ],
    );
  }
}
