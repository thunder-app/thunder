import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:lemmy_api_client/v3.dart';

import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/src/core/models/models.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/app/utils/global_context.dart';
import 'package:thunder/src/app/utils/navigation.dart';
import 'package:thunder/src/shared/markdown/common_markdown_body.dart';
import 'package:thunder/src/shared/widgets/avatars/user_avatar.dart';
import 'package:thunder/src/shared/full_name_widgets.dart';
import 'package:thunder/src/shared/utils/date_time.dart';
import 'package:thunder/src/shared/utils/instance.dart';

/// A widget that displays information about a community.
class CommunityInformation extends StatelessWidget {
  /// The community to display in the sidebar
  final ThunderCommunity community;

  /// The instance that the community is hosted on
  final ThunderSite? instance;

  /// The moderators of the community
  final List<ThunderUser> moderators;

  const CommunityInformation({
    super.key,
    required this.community,
    this.instance,
    required this.moderators,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommunityHeader(community: community, instance: instance, moderators: moderators, condensed: true),
          SidebarSectionHeader(value: l10n.information),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CommonMarkdownBody(body: community.description ?? '', imageMaxWidth: MediaQuery.of(context).size.width),
          ),
          SidebarSectionHeader(value: l10n.stats),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CommunityStatsList(community: community),
          ),
          if (moderators.isNotEmpty) ...[
            SidebarSectionHeader(value: l10n.moderator(2)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: CommunityModeratorList(moderators: moderators),
            ),
          ],
          SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 32.0),
        ],
      ),
    );
  }
}

/// A widget that displays statistics about a community.
class CommunityStatsList extends StatelessWidget {
  /// The community to display in the sidebar
  final ThunderCommunity community;

  const CommunityStatsList({super.key, required this.community});

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...[
          SidebarStat(
            icon: community.local ? Icons.house_rounded : Icons.language_rounded,
            value: l10n.visibility(community.local ? CommunityVisibility.localOnly : CommunityVisibility.public),
          ),
          const SizedBox(height: 8.0),
        ],
        SidebarStat(
          icon: Icons.cake_rounded,
          value: '${l10n.created(DateFormat.yMMMMd().format(community.published))} · ${l10n.ago(formatTimeToString(dateTime: community.published.toIso8601String()))}',
        ),
        const SizedBox(height: 8.0),
        SidebarStat(
          icon: Icons.people_rounded,
          value: l10n.countSubscribers(NumberFormat("#,###,###,###").format(community.subscribers)),
        ),
        if (community.subscribersLocal != null)
          SidebarStat(
            icon: Icons.people_rounded,
            value: l10n.countLocalSubscribers(NumberFormat("#,###,###,###").format(community.subscribersLocal)),
          ),
        SidebarStat(
          icon: Icons.wysiwyg_rounded,
          value: l10n.countPosts(NumberFormat("#,###,###,###").format(community.posts)),
        ),
        SidebarStat(
          icon: Icons.chat_rounded,
          value: l10n.countComments(NumberFormat("#,###,###,###").format(community.comments)),
        ),
        const SizedBox(height: 8.0),
        SidebarStat(
          icon: Icons.calendar_month_rounded,
          value: l10n.countUsersActiveHalfYear(NumberFormat("#,###,###,###").format(community.usersActiveHalfYear)),
        ),
        SidebarStat(
          icon: Icons.calendar_view_month_rounded,
          value: l10n.countUsersActiveMonth(NumberFormat("#,###,###,###").format(community.usersActiveMonth)),
        ),
        SidebarStat(
          icon: Icons.calendar_view_week_rounded,
          value: l10n.countUsersActiveWeek(NumberFormat("#,###,###,###").format(community.usersActiveWeek)),
        ),
        SidebarStat(
          icon: Icons.calendar_view_day_rounded,
          value: l10n.countUsersActiveDay(NumberFormat("#,###,###,###").format(community.usersActiveDay)),
        ),
      ],
    );
  }
}

/// A widget that displays a list of moderators for a community.
class CommunityModeratorList extends StatelessWidget {
  /// The moderators of the community
  final List<ThunderUser> moderators;

  const CommunityModeratorList({super.key, required this.moderators});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final moderator in moderators)
          InkWell(
            onTap: () => navigateToFeedPage(context, feedType: FeedType.user, userId: moderator.id),
            borderRadius: BorderRadius.circular(50),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                spacing: 16.0,
                children: [
                  UserAvatar(user: moderator, radius: 20.0),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.55,
                        child: Text(
                          moderator.displayNameOrName,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                        ),
                      ),
                      UserFullNameWidget(
                        context,
                        moderator.name,
                        moderator.displayName,
                        fetchInstanceNameFromUrl(moderator.actorId),
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
