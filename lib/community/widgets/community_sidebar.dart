import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/enums/community_action.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/models/models.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/feed/bloc/feed_bloc.dart';
import 'package:thunder/feed/view/feed_page.dart';
import 'package:thunder/instance/widgets/instance_view.dart';
import 'package:thunder/user/widgets/user_sidebar.dart';
import 'package:thunder/utils/navigation.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/avatars/user_avatar.dart';
import 'package:thunder/shared/full_name_widgets.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/instance.dart';

const kSidebarWidthFactor = 0.8;

class CommunitySidebar extends StatefulWidget {
  /// The community to display in the sidebar
  final ThunderCommunity? community;

  /// The instance that the community is hosted on
  final ThunderInstance? instance;

  /// The moderators of the community
  final List<ThunderUser>? moderators;

  /// The function to call when the sidebar is dismissed
  final Function onDismiss;

  const CommunitySidebar({super.key, this.community, this.instance, this.moderators, required this.onDismiss});

  @override
  State<CommunitySidebar> createState() => _CommunitySidebarState();
}

class _CommunitySidebarState extends State<CommunitySidebar> {
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
    final isLoggedIn = context.read<AuthBloc>().state.isLoggedIn;

    if (widget.community == null) return Container();

    return BlocProvider<CommunityBloc>(
      create: (context) => CommunityBloc(lemmyClient: LemmyClient.instance),
      child: BlocListener<CommunityBloc, CommunityState>(
        listener: (context, state) {
          if (state.status == CommunityStatus.success && state.community != null) {
            context.read<FeedBloc>().add(FeedCommunityUpdatedEvent(community: state.community!));
          }
        },
        child: Container(
          alignment: Alignment.centerRight,
          child: Dismissible(
            key: Key(widget.community!.id.toString()),
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
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return SizeTransition(
                          sizeFactor: animation,
                          child: FadeTransition(opacity: animation, child: child),
                        );
                      },
                      child: widget.community!.blocked == false
                          ? Padding(
                              padding: const EdgeInsets.only(top: 10, left: 12, right: 12, bottom: 4),
                              child: CommunityActions(isUserLoggedIn: isLoggedIn, community: widget.community!),
                            )
                          : null,
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return SizeTransition(
                          sizeFactor: animation,
                          child: FadeTransition(opacity: animation, child: child),
                        );
                      },
                      child: widget.community!.subscribed != SubscribedType.subscribed && widget.community!.subscribed != SubscribedType.pending
                          ? BlockCommunityButton(communityId: widget.community!.id, isUserLoggedIn: isLoggedIn)
                          : null,
                    ),
                    const SizedBox(height: 10.0),
                    const Divider(height: 1, thickness: 2),
                    const SizedBox(height: 10.0),
                    Container(
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      height: MediaQuery.of(context).size.height - 200,
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Material(
                            child: CommonMarkdownBody(
                              body: widget.community?.description ?? '',
                              imageMaxWidth: (kSidebarWidthFactor - 0.1) * MediaQuery.of(context).size.width,
                            ),
                          ),
                          SidebarSectionHeader(value: l10n.stats),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: CommunityStatsList(community: widget.community!),
                          ),
                          SidebarSectionHeader(value: l10n.moderator(2)),
                          CommunityModeratorList(moderators: widget.moderators!),
                          Container(
                            child: widget.instance != null
                                ? Column(
                                    children: [
                                      SidebarSectionHeader(value: l10n.hostInstance),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: InstanceView(
                                          site: widget.instance!,
                                        ),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
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

class CommunityStatsList extends StatelessWidget {
  /// The community to display in the sidebar
  final ThunderCommunity community;

  const CommunityStatsList({super.key, required this.community});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (community.local != null) ...[
          SidebarStat(
            icon: community.local! ? Icons.house_rounded : Icons.language_rounded,
            value: l10n.visibility(community.local! ? CommunityVisibility.localOnly : CommunityVisibility.public),
          ),
          const SizedBox(height: 8.0),
        ],
        // TODO Make this use device date format
        SidebarStat(
          icon: Icons.cake_rounded,
          value: '${l10n.created(DateFormat.yMMMMd().format(community.created))} · ${l10n.ago(formatTimeToString(dateTime: community.created.toIso8601String()))}',
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
          value: l10n.countPosts(NumberFormat("#,###,###,###").format(community.totalPosts)),
        ),
        SidebarStat(
          icon: Icons.chat_rounded,
          value: l10n.countComments(NumberFormat("#,###,###,###").format(community.totalComments)),
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

class CommunityModeratorList extends StatelessWidget {
  /// The moderators of the community
  final List<ThunderUser> moderators;

  const CommunityModeratorList({super.key, required this.moderators});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final moderator in moderators)
          Material(
            child: InkWell(
              onTap: () => navigateToFeedPage(context, feedType: FeedType.user, userId: moderator.id),
              borderRadius: BorderRadius.circular(50),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    UserAvatar(user: moderator, radius: 20.0),
                    const SizedBox(width: 16.0),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.55,
                          child: Text(
                            moderator.name,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        UserFullNameWidget(
                          context,
                          moderator.username,
                          moderator.displayName,
                          fetchInstanceNameFromUrl(moderator.url),
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

class BlockCommunityButton extends StatelessWidget {
  /// The id of the community to block
  final int communityId;

  /// Whether the current user is logged in.
  final bool isUserLoggedIn;

  const BlockCommunityButton({
    super.key,
    required this.communityId,
    required this.isUserLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        bool blocked = false;

        if (state.getSiteResponse?.myUser?.communityBlocks != null) {
          List<ThunderCommunity> blockedCommunities = state.getSiteResponse!.myUser!.communityBlocks.map((block) => ThunderCommunity(block.community)).toList();
          final blockedCommunity = blockedCommunities.firstWhereOrNull((blockedCommunity) => blockedCommunity.id == communityId);
          if (blockedCommunity != null) blocked = true;
        }

        return Padding(
          padding: EdgeInsets.only(top: blocked ? 10 : 4, left: 12, right: 12, bottom: 4),
          child: ElevatedButton(
            onPressed: isUserLoggedIn
                ? () {
                    HapticFeedback.heavyImpact();
                    context.read<CommunityBloc>().add(CommunityActionEvent(communityAction: CommunityAction.block, communityId: communityId, value: !blocked));
                  }
                : null,
            style: TextButton.styleFrom(
              fixedSize: const Size.fromHeight(40),
              foregroundColor: Colors.redAccent,
              padding: EdgeInsets.zero,
            ),
            child: Row(
              spacing: 4.0,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(blocked ? Icons.undo_rounded : Icons.block_rounded),
                Text(blocked ? l10n.unblockCommunity : l10n.blockCommunity),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CommunityActions extends StatelessWidget {
  /// The community to display in the sidebar
  final ThunderCommunity community;

  /// Whether the user is logged in
  final bool isUserLoggedIn;

  const CommunityActions({super.key, required this.community, required this.isUserLoggedIn});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    assert(community.subscribed != null);

    return Row(
      spacing: 10.0,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: isUserLoggedIn
                ? () async {
                    HapticFeedback.mediumImpact();
                    navigateToCreatePostPage(context, communityId: community.id, community: community);
                  }
                : null,
            style: TextButton.styleFrom(fixedSize: const Size.fromHeight(40), foregroundColor: null, padding: EdgeInsets.zero),
            child: Semantics(
              focused: true,
              child: Row(
                spacing: 4.0,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.library_books_rounded),
                  Text(l10n.newPost),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            onPressed: isUserLoggedIn
                ? () {
                    HapticFeedback.mediumImpact();
                    context.read<CommunityBloc>().add(
                          CommunityActionEvent(
                            communityAction: CommunityAction.follow,
                            communityId: community.id,
                            value: community.subscribed == SubscribedType.notSubscribed ? true : false,
                          ),
                        );
                  }
                : null,
            style: TextButton.styleFrom(fixedSize: const Size.fromHeight(40), foregroundColor: null, padding: EdgeInsets.zero),
            child: Row(
              spacing: 4.0,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  switch (community.subscribed!) {
                    SubscribedType.notSubscribed => Icons.add_circle_outline_rounded,
                    SubscribedType.pending => Icons.pending_outlined,
                    SubscribedType.subscribed => Icons.remove_circle_outline_rounded,
                  },
                ),
                Text(
                  switch (community.subscribed!) {
                    SubscribedType.notSubscribed => l10n.subscribe,
                    SubscribedType.pending => '${l10n.pending}...',
                    SubscribedType.subscribed => l10n.unsubscribe,
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
