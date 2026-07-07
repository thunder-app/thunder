import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/features/feed/feed.dart';
import 'package:thunder/src/shared/avatars/community_avatar.dart';
import 'package:thunder/src/shared/markdown/common_markdown_body.dart';
import 'package:thunder/src/shared/name/full_name_widgets.dart';
import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/foundation/utils/utils.dart';
import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/features/instance/domain/utils/instance_link_utils.dart';
import 'package:thunder/src/app/shell/navigation/navigation_utils.dart';

/// A widget that displays detailed information about a user.
class UserInformation extends StatefulWidget {
  final BuildContext launchContext;
  final Account account;

  /// The user to display in the sidebar.
  final ThunderUser user;

  /// The communities that the user moderates.
  final List<ThunderCommunity> moderates;

  const UserInformation({
    super.key,
    required this.launchContext,
    required this.account,
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
          ThunderSectionHeader(title: l10n.profileBio, variant: ThunderSectionHeaderVariant.sidebar),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CommonMarkdownBody(body: widget.user.bio ?? '_${l10n.noProfileBioSet}_', imageMaxWidth: MediaQuery.of(context).size.width, launchContext: widget.launchContext),
          ),
          ThunderSectionHeader(title: l10n.stats, variant: ThunderSectionHeaderVariant.sidebar),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: UserStatsList(user: widget.user),
          ),
          ThunderSectionHeader(title: l10n.activity, variant: ThunderSectionHeaderVariant.sidebar),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: UserActivityList(user: widget.user),
          ),
          if (widget.moderates.isNotEmpty) ...[
            ThunderSectionHeader(title: l10n.moderates, variant: ThunderSectionHeaderVariant.sidebar),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: UserModeratorList(launchContext: widget.launchContext, account: widget.account, moderates: widget.moderates),
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
        ThunderSidebarStat(
          icon: Icons.cake_rounded,
          label: '${l10n.joined(DateFormat.yMMMMd().format(user.published))} · ${l10n.ago(formatTimeToString(dateTime: user.published.toIso8601String()))}',
        ),
        const SizedBox(height: 8.0),
        ThunderSidebarStat(
          icon: Icons.wysiwyg_rounded,
          label: l10n.totalPosts(NumberFormat("#,###,###,###").format(user.counts.posts)),
        ),
        ThunderSidebarStat(
          icon: Icons.chat_rounded,
          label: l10n.totalComments(NumberFormat("#,###,###,###").format(user.counts.comments)),
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

    final totalContributions = ((user.counts.posts ?? 0) + (user.counts.comments ?? 0));
    final totalContributionsPerMonth = (totalContributions / (accountAgeMonths < 1 ? 1 : accountAgeMonths));

    int postsPerMonth;
    int commentsPerMonth;

    if (user.counts.posts != null && user.counts.posts != 0) {
      postsPerMonth = (user.counts.posts! / (accountAgeMonths < 1 ? 1 : accountAgeMonths)).truncate();
    } else {
      postsPerMonth = 0;
    }

    if (user.counts.comments != null && user.counts.comments != 0) {
      commentsPerMonth = (user.counts.comments! / (accountAgeMonths < 1 ? 1 : accountAgeMonths)).truncate();
    } else {
      commentsPerMonth = 0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ThunderSidebarStat(
          icon: Icons.wysiwyg_rounded,
          label: l10n.averagePosts(NumberFormat("#,###,###,###").format(postsPerMonth)),
        ),
        ThunderSidebarStat(
          icon: Icons.chat_rounded,
          label: l10n.averageComments(NumberFormat("#,###,###,###").format(commentsPerMonth)),
        ),
        ThunderSidebarStat(
          icon: Icons.score_rounded,
          label: l10n.averageContributions(NumberFormat("#,###,###,###").format(totalContributionsPerMonth)),
        ),
      ],
    );
  }
}

/// A widget that displays a list of communities moderated by a user.
class UserModeratorList extends StatelessWidget {
  final BuildContext launchContext;
  final Account account;

  /// The communities that the user moderates.
  final List<ThunderCommunity> moderates;

  const UserModeratorList({super.key, required this.launchContext, required this.account, required this.moderates});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final community in moderates)
          InkWell(
            onTap: () => navigateToFeedPage(launchContext, account: account, feedType: FeedType.community, communityId: community.id),
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
                        name: community.name,
                        displayName: community.title,
                        instance: fetchInstanceNameFromUrl(community.actorId),
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
