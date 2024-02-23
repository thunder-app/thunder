import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/full_name_separator.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/utils/utils.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/shared/avatars/community_avatar.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/user/bloc/user_bloc.dart';
import 'package:thunder/user/bloc/user_bloc_old.dart' as user_bloc;
import 'package:thunder/user/enums/user_action.dart';
import 'package:thunder/user/utils/navigate_user.dart';
import 'package:thunder/user/widgets/user_sidebar_activity.dart';
import 'package:thunder/user/widgets/user_sidebar_stats.dart';
import 'package:thunder/utils/instance.dart';

import '../../shared/common_markdown_body.dart';
import '../../thunder/bloc/thunder_bloc.dart';
import '../../utils/date_time.dart';

const kSidebarWidthFactor = 0.8;

class UserSidebarOld extends StatefulWidget {
  final PersonView? userInfo;
  final List<CommunityModeratorView>? moderates;
  final bool isAccountUser;
  final List<PersonBlockView>? personBlocks;
  final BlockPersonResponse? blockedPerson;

  const UserSidebarOld({
    super.key,
    required this.userInfo,
    required this.moderates,
    required this.isAccountUser,
    this.personBlocks,
    this.blockedPerson,
  });

  @override
  State<UserSidebarOld> createState() => _UserSidebarOldState();
}

class _UserSidebarOldState extends State<UserSidebarOld> {
  final ScrollController _scrollController = ScrollController();
  bool isBlocked = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    //custom stats
    final totalContributions = (widget.userInfo!.counts.postCount + widget.userInfo!.counts.commentCount);
    final totalScore = ((widget.userInfo!.counts.postScore?.toInt() ?? 0) + (widget.userInfo!.counts.commentScore?.toInt() ?? 0));
    Duration accountAge = DateTime.now().difference(widget.userInfo!.person.published);
    final accountAgeMonths = ((accountAge.inDays) / 30).toDouble();
    final num postsPerMonth;
    final num commentsPerMonth;
    final totalContributionsPerMonth = (totalContributions / accountAgeMonths);
    final ThunderState state = context.read<ThunderBloc>().state;
    bool scoreCounters = state.scoreCounters;

    if (widget.userInfo!.counts.postCount != 0) {
      postsPerMonth = (widget.userInfo!.counts.postCount / accountAgeMonths);
    } else {
      postsPerMonth = 0;
    }

    if ((widget.userInfo!.counts.commentCount).toInt() != 0) {
      commentsPerMonth = (widget.userInfo!.counts.commentCount / accountAgeMonths);
    } else {
      commentsPerMonth = 0;
    }

    bool isLoggedIn = context.read<AuthBloc>().state.isLoggedIn;

    if (widget.personBlocks != null) {
      for (var user in widget.personBlocks!) {
        if (user.person.id == widget.userInfo!.person.id) {
          isBlocked = true;
        }
      }
    }

    if (widget.blockedPerson != null) {
      isBlocked = widget.blockedPerson!.blocked;
    }

    return Container(
      alignment: Alignment.topRight,
      child: FractionallySizedBox(
        widthFactor: kSidebarWidthFactor,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.alphaBlend(Colors.black.withOpacity(0.25), theme.colorScheme.background),
                          theme.colorScheme.background,
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: theme.colorScheme.background,
                    ),
                  ),
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        end: Alignment.topCenter,
                        begin: Alignment.bottomCenter,
                        colors: [
                          Color.alphaBlend(Colors.black.withOpacity(0.25), theme.colorScheme.background),
                          theme.colorScheme.background,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    child: !widget.isAccountUser
                        ? Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  left: 12,
                                  right: 12,
                                  bottom: 4,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: isLoggedIn
                                            ? () {
                                                HapticFeedback.heavyImpact();
                                                context.read<user_bloc.UserBloc>().add(
                                                      user_bloc.BlockUserEvent(
                                                        personId: widget.userInfo!.person.id,
                                                        blocked: isBlocked == true ? false : true,
                                                      ),
                                                    );
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
                                            Icon(
                                              isBlocked == true ? Icons.undo_rounded : Icons.block,
                                              semanticLabel: isBlocked == true ? 'Unblock User' : 'Block User',
                                            ),
                                            const SizedBox(width: 4.0),
                                            Text(
                                              isBlocked == true ? 'Unblock User' : 'Block User',
                                              style: const TextStyle(
                                                color: null,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(),
                            ],
                          )
                        : null,
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 6.0, bottom: 6),
                                child: Row(children: [
                                  Text("Bio"),
                                  Expanded(
                                    child: Divider(
                                      height: 5,
                                      thickness: 2,
                                      indent: 15,
                                      endIndent: 5,
                                    ),
                                  ),
                                ]),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 8.0,
                                  right: 8,
                                  bottom: 8,
                                ),
                                child: Material(
                                  child: CommonMarkdownBody(
                                    body: widget.userInfo?.person.bio ?? 'Nothing here. This user has not written a bio.',
                                    imageMaxWidth: (kSidebarWidthFactor - 0.1) * MediaQuery.of(context).size.width,
                                    allowHorizontalTranslation: false,
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 10.0, bottom: 6),
                                child: Row(children: [
                                  Text("Stats"),
                                  Expanded(
                                    child: Divider(
                                      height: 5,
                                      thickness: 2,
                                      indent: 15,
                                      endIndent: 5,
                                    ),
                                  ),
                                ]),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 3.0),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                                        child: Icon(
                                          Icons.cake_rounded,
                                          size: 18,
                                          color: theme.colorScheme.onBackground.withOpacity(0.65),
                                        ),
                                      ),
                                      // TODO Make this use device date format
                                      Text(
                                        'Joined ${DateFormat.yMMMMd().format(widget.userInfo!.person.published)} · ${formatTimeToString(dateTime: widget.userInfo!.person.published.toIso8601String())} ago',
                                        style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.65)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3.0),
                                  UserSidebarStats(
                                    icon: Icons.wysiwyg_rounded,
                                    label: ' Posts',
                                    metric: NumberFormat("#,###,###,###").format(widget.userInfo!.counts.postCount),
                                    scoreLabel: widget.userInfo!.counts.postScore == null ? 'No score available' : ' Score',
                                    scoreMetric: widget.userInfo!.counts.postScore == null ? '' : NumberFormat("#,###,###,###").format(widget.userInfo!.counts.postScore),
                                  ),
                                  const SizedBox(height: 3.0),
                                  UserSidebarStats(
                                    icon: Icons.chat_rounded,
                                    label: ' Comments',
                                    metric: NumberFormat("#,###,###,###").format(widget.userInfo!.counts.commentCount),
                                    scoreLabel: widget.userInfo!.counts.commentScore == null ? 'No score available' : ' Score',
                                    scoreMetric: widget.userInfo!.counts.commentScore == null ? '' : NumberFormat("#,###,###,###").format(widget.userInfo!.counts.commentScore),
                                  ),
                                  const SizedBox(height: 3.0),
                                  Visibility(
                                      visible: scoreCounters,
                                      child: UserSidebarActivity(
                                        icon: Icons.celebration_rounded,
                                        scoreLabel: totalScore == 0 ? 'Score not available' : ' Total Score',
                                        scoreMetric: totalScore == 0 ? '' : NumberFormat("#,###,###,###").format(totalScore),
                                      )),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 12.0, bottom: 6),
                                child: Row(children: [
                                  Text("Activity"),
                                  Expanded(
                                    child: Divider(
                                      height: 5,
                                      thickness: 2,
                                      indent: 15,
                                      endIndent: 5,
                                    ),
                                  ),
                                ]),
                              ),
                              UserSidebarActivity(
                                icon: Icons.wysiwyg_rounded,
                                scoreLabel: ' Average Posts/mo',
                                scoreMetric: NumberFormat("#,###,###,###").format(postsPerMonth),
                              ),
                              const SizedBox(height: 3.0),
                              UserSidebarActivity(
                                icon: Icons.chat_rounded,
                                scoreLabel: ' Average Comments/mo',
                                scoreMetric: NumberFormat("#,###,###,###").format(commentsPerMonth),
                              ),
                              const SizedBox(height: 3.0),
                              UserSidebarActivity(
                                icon: Icons.score_rounded,
                                scoreLabel: ' Average Contributions/mo',
                                scoreMetric: NumberFormat("#,###,###,###").format(totalContributionsPerMonth),
                              ),
                              Container(
                                child: widget.moderates!.isNotEmpty
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.only(top: 16.0, bottom: 8),
                                            child: Row(children: [
                                              Text("Moderates"),
                                              Expanded(
                                                child: Divider(
                                                  height: 5,
                                                  thickness: 2,
                                                  indent: 15,
                                                  endIndent: 5,
                                                ),
                                              ),
                                            ]),
                                          ),
                                          Column(
                                            children: [
                                              for (var mods in widget.moderates!)
                                                Material(
                                                  child: InkWell(
                                                    borderRadius: BorderRadius.circular(50),
                                                    onTap: () => navigateToFeedPage(context, feedType: FeedType.community, communityId: mods.community.id),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Row(
                                                        children: [
                                                          CommunityAvatar(community: mods.community, radius: 20.0),
                                                          const SizedBox(width: 16.0),
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  mods.community.title,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  maxLines: 1,
                                                                  style: const TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 16,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  generateCommunityFullName(context, mods.community.name, fetchInstanceNameFromUrl(mods.community.actorId)),
                                                                  overflow: TextOverflow.ellipsis,
                                                                  style: TextStyle(
                                                                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                                                                    fontSize: 13,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 128,
                        )
                      ],
                    ),
                  ),
                  Container(
                    child: widget.isAccountUser
                        ? Column(
                            children: [
                              const Divider(
                                height: 0,
                                thickness: 2,
                              ),
                              const SizedBox(height: 10.0),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10.0, left: 12, right: 12),
                                child: ElevatedButton(
                                  onPressed: null /*() {
                              HapticFeedback.mediumImpact();
                            }*/
                                  ,
                                  style: TextButton.styleFrom(
                                    fixedSize: const Size.fromHeight(40),
                                    foregroundColor: null,
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        semanticLabel: 'Edit Profile',
                                      ),
                                      SizedBox(width: 4.0),
                                      Text(
                                        'Edit Profile',
                                        style: TextStyle(
                                          color: null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
        child: Container(
          alignment: Alignment.centerRight,
          child: Dismissible(
            key: Key(personView.person.id.toString()),
            onUpdate: (DismissUpdateDetails details) => details.reached ? widget.onDismiss() : null,
            direction: DismissDirection.startToEnd,
            child: FractionallySizedBox(
              widthFactor: kSidebarWidthFactor,
              alignment: FractionalOffset.centerRight,
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
                    const SizedBox(height: 10.0),
                    const Divider(height: 1, thickness: 2),
                    Container(
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      height: MediaQuery.of(context).size.height - 200,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Material(
                            child: CommonMarkdownBody(
                              body: personView.person.bio ?? 'Nothing here. This user has not written a bio.',
                              imageMaxWidth: (kSidebarWidthFactor - 0.1) * MediaQuery.of(context).size.width,
                              allowHorizontalTranslation: false,
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
                        Text(
                          mods.community.title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          generateCommunityFullName(context, mods.community.name, fetchInstanceNameFromUrl(mods.community.actorId)),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.colorScheme.onBackground.withOpacity(0.6),
                            fontSize: 13,
                          ),
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
          padding: EdgeInsets.only(top: blocked ? 10 : 4, left: 12, right: 12, bottom: 4),
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
