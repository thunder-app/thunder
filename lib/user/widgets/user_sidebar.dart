import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';

import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/sidebar.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/user/bloc/user_bloc.dart';
import 'package:thunder/utils/date_time.dart';

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
    final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;

    if (widget.getPersonDetailsResponse == null) return Container();

    PersonView personView = widget.getPersonDetailsResponse!.personView;

    return Sidebar(
      onDismiss: widget.onDismiss,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SizeTransition(
              sizeFactor: animation,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: BlockUserButton(personView: personView, isUserLoggedIn: isUserLoggedIn),
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
              const SidebarSectionHeader(value: "Bio"),
              CommonMarkdownBody(body: personView.person.bio ?? 'Nothing here. This user has not written a bio.'),
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
              if (widget.getPersonDetailsResponse!.moderates.isNotEmpty) ...[
                const SidebarSectionHeader(value: "Moderates"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: CommunityModeratorList(communityModeratorViewList: widget.getPersonDetailsResponse!.moderates),
                ),
              ],
              const SizedBox(height: 256)
            ],
          ),
        )
      ],
    );
  }
}

class UserStatsList extends StatelessWidget {
  const UserStatsList({super.key, required this.personView});

  final PersonView personView;

  @override
  Widget build(BuildContext context) {
    final ThunderState state = context.read<ThunderBloc>().state;
    bool scoreCounters = state.scoreCounters;
    final totalScore = (personView.counts.postScore + personView.counts.commentScore);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SidebarStat(
          icon: Icons.cake_rounded,
          value: 'Created ${DateFormat.yMMMMd().format(personView.person.published)} · ${formatTimeToString(dateTime: personView.person.published.toIso8601String())} ago',
        ),
        const SizedBox(height: 8.0),
        SidebarStat(
          icon: Icons.wysiwyg_rounded,
          value: '${NumberFormat("#,###,###,###").format(personView.counts.postCount)} Posts · ${NumberFormat("#,###,###,###").format(personView.counts.postScore)} Score',
        ),
        SidebarStat(
          icon: Icons.chat_rounded,
          value: '${NumberFormat("#,###,###,###").format(personView.counts.commentCount)} Comments · ${NumberFormat("#,###,###,###").format(personView.counts.commentScore)} Score',
        ),
        Visibility(
          visible: scoreCounters,
          child: SidebarStat(
            icon: Icons.celebration_rounded,
            value: 'Total Score: ${NumberFormat("#,###,###,###").format(totalScore)} ',
          ),
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
    final counts = personView.counts;

    final accountAge = DateTime.now().difference(personView.person.published);
    final accountAgeMonths = ((accountAge.inDays) / 30).toDouble();

    final postsPerMonth = counts.postCount > 0 ? (counts.postCount / accountAgeMonths) : 0;
    final commentsPerMonth = counts.commentCount > 0 ? (counts.commentCount / accountAgeMonths) : 0;

    final totalContributions = (personView.counts.postCount + personView.counts.commentCount);
    final totalContributionsPerMonth = (totalContributions / accountAgeMonths);

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
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        bool blocked = false;

        // if (state.personView != null) {
        //   blocked = state.personView!.blocked;
        // } else {
        //   blocked = communityView.blocked;
        // }

        return Padding(
          padding: EdgeInsets.only(top: blocked ? 10 : 4, left: 12, right: 12, bottom: 4),
          child: ElevatedButton(
            onPressed: isUserLoggedIn
                ? () {
                    HapticFeedback.heavyImpact();
                    hideSnackbar(context);
                    // context.read<CommunityBloc>().add(CommunityActionEvent(communityAction: CommunityAction.block, communityId: communityView.community.id, value: !blocked));
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
