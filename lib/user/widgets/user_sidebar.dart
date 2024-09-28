import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/shared/avatars/community_avatar.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/full_name_widgets.dart';
import 'package:thunder/user/bloc/user_bloc.dart';
import 'package:thunder/user/enums/user_action.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/instance.dart';

const kSidebarWidthFactor = 0.8;

class UserSidebar extends StatefulWidget {
  final GetPersonDetailsResponse? getPersonDetailsResponse;
  final Function onDismiss;

  const UserSidebar({super.key, this.getPersonDetailsResponse, required this.onDismiss});

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
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState.account?.userId;

    if (widget.getPersonDetailsResponse == null) return Container();

    PersonView personView = widget.getPersonDetailsResponse!.personView;

    return BlocProvider<UserBloc>(
      create: (context) => UserBloc(lemmyClient: LemmyClient.instance),
      child: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state.status == UserStatus.success && state.personView != null) {
            context.read<AuthBloc>().add(LemmyAccountSettingUpdated());
          }
        },
        child: SingleChildScrollView(
          child: Dismissible(
            key: Key(personView.person.id.toString()),
            onUpdate: (DismissUpdateDetails details) => details.reached ? widget.onDismiss() : null,
            direction: DismissDirection.startToEnd,
            child: Container(
              color: theme.colorScheme.background,
              alignment: Alignment.topRight,
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return SizeTransition(
                        sizeFactor: animation,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: personView.person.id != currentUserId ? BlockUserButton(personView: personView, isUserLoggedIn: authState.isLoggedIn) : null,
                  ),
                  if (personView.person.id != currentUserId) const SizedBox(height: 10.0),
                  if (personView.person.id != currentUserId) const Divider(height: 1, thickness: 2),
                  Container(
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    height: MediaQuery.of(context).size.height - 200,
                    child: ListView(
                      padding: const EdgeInsets.only(top: 12.0),
                      shrinkWrap: true,
                      children: [
                        Material(
                          child: CommonMarkdownBody(
                            body: personView.person.bio ?? 'Nothing here. This user has not written a bio.',
                            imageMaxWidth: (kSidebarWidthFactor - 0.1) * MediaQuery.of(context).size.width,
                          ),
                        ),
                        const SidebarSectionHeader(value: "Stats"),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: UserStatsList(personView: personView),
                        ),
                        const SidebarSectionHeader(value: "Activity"),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: UserActivityList(personView: personView),
                        ),
                        const SidebarSectionHeader(value: "Moderates"),
                        UserModeratorList(getPersonDetailsResponse: widget.getPersonDetailsResponse!),
                        const SizedBox(height: 256)
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UserStatsList extends StatelessWidget {
  const UserStatsList({super.key, required this.personView});

  final PersonView personView;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // TODO Make this use device date format
        SidebarStat(
          icon: Icons.cake_rounded,
          value: 'Joined ${DateFormat.yMMMMd().format(personView.person.published)} · ${formatTimeToString(dateTime: personView.person.published.toIso8601String())} ago',
        ),
        const SizedBox(height: 8.0),
        SidebarStat(
          icon: Icons.wysiwyg_rounded,
          value: '${NumberFormat("#,###,###,###").format(personView.counts.postCount)} Posts',
        ),
        SidebarStat(
          icon: Icons.chat_rounded,
          value: '${NumberFormat("#,###,###,###").format(personView.counts.commentCount)} Comments',
        ),
      ],
    );
  }
}

class UserActivityList extends StatelessWidget {
  const UserActivityList({super.key, required this.personView});

  final PersonView personView;

  @override
  Widget build(BuildContext context) {
    final totalContributions = (personView.counts.postCount + personView.counts.commentCount);
    Duration accountAge = DateTime.now().difference(personView.person.published);
    final accountAgeMonths = ((accountAge.inDays) / 30).toDouble();

    final num postsPerMonth;
    final num commentsPerMonth;
    final totalContributionsPerMonth = (totalContributions / accountAgeMonths);

    if (personView.counts.postCount != 0) {
      postsPerMonth = (personView.counts.postCount / accountAgeMonths);
    } else {
      postsPerMonth = 0;
    }

    if (personView.counts.commentCount.toInt() != 0) {
      commentsPerMonth = (personView.counts.commentCount / accountAgeMonths);
    } else {
      commentsPerMonth = 0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SidebarStat(
          icon: Icons.wysiwyg_rounded,
          value: '${NumberFormat("#,###,###,###").format(postsPerMonth)} Average Posts/mo',
        ),
        SidebarStat(
          icon: Icons.chat_rounded,
          value: '${NumberFormat("#,###,###,###").format(commentsPerMonth)} Average Comments/mo',
        ),
        SidebarStat(
          icon: Icons.score_rounded,
          value: '${NumberFormat("#,###,###,###").format(totalContributionsPerMonth)} Average Contributions/mo',
        ),
      ],
    );
  }
}

class UserModeratorList extends StatelessWidget {
  const UserModeratorList({super.key, required this.getPersonDetailsResponse});

  final GetPersonDetailsResponse getPersonDetailsResponse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        for (CommunityModeratorView mods in getPersonDetailsResponse.moderates)
          Material(
            child: InkWell(
              onTap: () => navigateToFeedPage(context, feedType: FeedType.community, communityId: mods.community.id),
              borderRadius: BorderRadius.circular(50),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    CommunityAvatar(
                      community: mods.community,
                      radius: 20.0,
                    ),
                    const SizedBox(width: 16.0),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.55,
                          child: Text(
                            mods.community.title,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        CommunityFullNameWidget(
                          context,
                          mods.community.name,
                          mods.community.title,
                          fetchInstanceNameFromUrl(mods.community.actorId),
                          textStyle: const TextStyle(
                            fontSize: 13,
                          ),
                          transformColor: (color) => color?.withOpacity(0.6),
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
  const BlockUserButton({
    super.key,
    required this.personView,
    required this.isUserLoggedIn,
  });

  final PersonView personView;
  final bool isUserLoggedIn;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        bool blocked = false;

        if (state.getSiteResponse?.myUser?.personBlocks != null) {
          for (PersonBlockView personBlockView in state.getSiteResponse!.myUser!.personBlocks) {
            if (personBlockView.target.id == personView.person.id) {
              blocked = true;
              break;
            }
          }
        }

        return Padding(
          padding: const EdgeInsets.only(top: 10, left: 12, right: 12, bottom: 4),
          child: ElevatedButton(
            onPressed: isUserLoggedIn
                ? () {
                    HapticFeedback.heavyImpact();
                    context.read<UserBloc>().add(UserActionEvent(userAction: UserAction.block, userId: personView.person.id, value: !blocked));
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
                Icon(blocked ? Icons.undo_rounded : Icons.block_rounded),
                const SizedBox(width: 4.0),
                Text(blocked ? 'Unblock User' : 'Block User'),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SidebarSectionHeader extends StatelessWidget {
  const SidebarSectionHeader({
    super.key,
    required this.value,
  });

  final String value;

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
  const SidebarStat({
    super.key,
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;

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
            color: theme.colorScheme.onBackground.withOpacity(0.65),
          ),
        ),
        Text(
          value,
          style: TextStyle(color: theme.textTheme.titleSmall?.color?.withOpacity(0.65)),
        ),
      ],
    );
  }
}
