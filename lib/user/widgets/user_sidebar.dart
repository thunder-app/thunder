import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/shared/avatars/community_avatar.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/full_name_widgets.dart';
import 'package:thunder/user/bloc/user_bloc.dart';
import 'package:thunder/user/enums/user_action.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/navigation.dart';

const kSidebarWidthFactor = 0.8;

class UserSidebar extends StatefulWidget {
  /// The user to display in the sidebar.
  final ThunderUser? user;

  /// The communities that the user moderates.
  final List<ThunderCommunity>? moderatedCommunities;

  /// Callback function that triggers when the sidebar is dismissed.
  final Function onDismiss;

  const UserSidebar({
    super.key,
    this.user,
    this.moderatedCommunities,
    required this.onDismiss,
  });

  @override
  State<UserSidebar> createState() => _UserSidebarState();
}

class _UserSidebarState extends State<UserSidebar> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState.account?.userId;

    if (widget.user == null) return Container();
    assert(widget.user?.admin != null);

    return BlocProvider<UserBloc>(
      create: (context) => UserBloc(lemmyClient: LemmyClient.instance),
      child: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state.status == UserStatus.success && state.personView != null) {
            context.read<AuthBloc>().add(LemmyAccountSettingUpdated());
          }
        },
        child: Container(
          alignment: Alignment.centerRight,
          child: Dismissible(
            key: Key(widget.user!.id.toString()),
            onUpdate: (DismissUpdateDetails details) => details.reached ? widget.onDismiss() : null,
            direction: DismissDirection.startToEnd,
            child: FractionallySizedBox(
              widthFactor: kSidebarWidthFactor,
              alignment: FractionalOffset.centerRight,
              child: Container(
                color: theme.colorScheme.surface,
                alignment: Alignment.topRight,
                child: Column(
                  children: [
                    // Note: admin is always defined at this point
                    if (widget.user!.id != currentUserId && widget.user?.admin == false) ...[
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return SizeTransition(
                            sizeFactor: animation,
                            child: FadeTransition(opacity: animation, child: child),
                          );
                        },
                        child: widget.user!.id != currentUserId ? BlockUserButton(userId: widget.user!.id, isUserLoggedIn: authState.isLoggedIn) : null,
                      ),
                      const SizedBox(height: 10.0),
                      const Divider(height: 1.0, thickness: 2.0),
                    ],
                    Container(
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      height: MediaQuery.of(context).size.height - 200,
                      child: ListView(
                        padding: const EdgeInsets.only(top: 12.0),
                        shrinkWrap: true,
                        children: [
                          SidebarSectionHeader(value: l10n.profileBio),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Material(
                              child: CommonMarkdownBody(
                                body: widget.user!.bio ?? '_${l10n.noProfileBioSet}_',
                                imageMaxWidth: (kSidebarWidthFactor - 0.1) * MediaQuery.of(context).size.width,
                              ),
                            ),
                          ),
                          SidebarSectionHeader(value: l10n.stats),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: UserStatsList(user: widget.user!),
                          ),
                          SidebarSectionHeader(value: l10n.activity),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: UserActivityList(user: widget.user!),
                          ),
                          if (widget.moderatedCommunities != null && widget.moderatedCommunities!.isNotEmpty) ...[
                            SidebarSectionHeader(value: l10n.moderates),
                            UserModeratorList(moderatedCommunities: widget.moderatedCommunities ?? []),
                          ],
                          const SizedBox(height: 256.0)
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UserStatsList extends StatelessWidget {
  /// The user to display the stats for.
  final ThunderUser user;

  const UserStatsList({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // TODO Make this use device date format
        SidebarStat(
          icon: Icons.cake_rounded,
          value: '${l10n.joined(DateFormat.yMMMMd().format(user.created))} · ${l10n.ago(formatTimeToString(dateTime: user.created.toIso8601String()))}',
        ),
        const SizedBox(height: 8.0),
        if (user.totalPosts != null)
          SidebarStat(
            icon: Icons.wysiwyg_rounded,
            value: l10n.totalPosts(NumberFormat("#,###,###,###").format(user.totalPosts)),
          ),
        if (user.totalComments != null)
          SidebarStat(
            icon: Icons.chat_rounded,
            value: l10n.totalComments(NumberFormat("#,###,###,###").format(user.totalComments)),
          ),
      ],
    );
  }
}

class UserActivityList extends StatelessWidget {
  /// The user to display the activity for.
  final ThunderUser user;

  const UserActivityList({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final accountAge = DateTime.now().difference(user.created);
    final accountAgeMonths = ((accountAge.inDays) / 30).toDouble();

    final totalContributions = ((user.totalPosts ?? 0) + (user.totalComments ?? 0));
    final totalContributionsPerMonth = (totalContributions / accountAgeMonths);

    int postsPerMonth;
    int commentsPerMonth;

    if (user.totalPosts != null && user.totalPosts != 0) {
      postsPerMonth = (user.totalPosts! / accountAgeMonths).truncate();
    } else {
      postsPerMonth = 0;
    }

    if (user.totalComments != null && user.totalComments != 0) {
      commentsPerMonth = (user.totalComments! / accountAgeMonths).truncate();
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

class UserModeratorList extends StatelessWidget {
  /// The communities that the user moderates.
  final List<ThunderCommunity> moderatedCommunities;

  const UserModeratorList({super.key, required this.moderatedCommunities});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final community in moderatedCommunities)
          Material(
            child: InkWell(
              onTap: () => navigateToFeedPage(context, feedType: FeedType.community, communityId: community.id),
              borderRadius: BorderRadius.circular(50),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    CommunityAvatar(community: community, radius: 20.0),
                    const SizedBox(width: 16.0),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.55,
                          child: Text(
                            community.title,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        CommunityFullNameWidget(
                          context,
                          community.communityName,
                          community.title,
                          fetchInstanceNameFromUrl(community.url),
                          textStyle: const TextStyle(fontSize: 13),
                          transformColor: (color) => color?.withValues(alpha: 0.6),
                          // Override because we're showing display name above
                          useDisplayName: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class BlockUserButton extends StatelessWidget {
  /// The id of the user being blocked.
  final int userId;

  /// Whether the current user is logged in.
  final bool isUserLoggedIn;

  const BlockUserButton({
    super.key,
    required this.userId,
    required this.isUserLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        bool blocked = false;

        if (state.getSiteResponse?.myUser?.personBlocks != null) {
          List<ThunderUser> blockedUsers = state.getSiteResponse!.myUser!.personBlocks.map((block) => ThunderUser(block.target)).toList();
          final blockedUser = blockedUsers.firstWhereOrNull((blockedUser) => blockedUser.id == userId);
          if (blockedUser != null) blocked = true;
        }

        return Padding(
          padding: const EdgeInsets.only(top: 10, left: 12, right: 12, bottom: 4),
          child: ElevatedButton(
            onPressed: isUserLoggedIn
                ? () {
                    HapticFeedback.heavyImpact();
                    context.read<UserBloc>().add(UserActionEvent(userAction: UserAction.block, userId: userId, value: !blocked));
                  }
                : null,
            style: TextButton.styleFrom(
              fixedSize: const Size.fromHeight(40),
              foregroundColor: Colors.redAccent,
              padding: EdgeInsets.zero,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(blocked ? Icons.undo_rounded : Icons.block_rounded, color: Colors.redAccent),
                const SizedBox(width: 4.0),
                Text(blocked ? l10n.unblockUser : l10n.blockUser),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SidebarSectionHeader extends StatelessWidget {
  /// The header title.
  final String value;

  const SidebarSectionHeader({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 4),
      child: Row(
        children: [
          Text(value),
          const Expanded(child: Divider(height: 5, thickness: 2, indent: 15)),
        ],
      ),
    );
  }
}

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
          padding: const EdgeInsets.only(right: 8, top: 2, bottom: 2),
          child: Icon(
            icon,
            size: 18,
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
