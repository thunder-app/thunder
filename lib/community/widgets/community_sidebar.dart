import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/enums/community_action.dart';
import 'package:thunder/community/pages/create_post_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/feed/feed.dart';
import 'package:thunder/instance/instance_view.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/shared/user_avatar.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/instance.dart';

class CommunitySidebar extends StatefulWidget {
  final GetCommunityResponse? getCommunityResponse;
  final Function onDismiss;

  const CommunitySidebar({super.key, this.getCommunityResponse, required this.onDismiss});

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
    final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;

    if (widget.getCommunityResponse == null) return Container();

    CommunityView communityView = widget.getCommunityResponse!.communityView;

    return BlocProvider<CommunityBloc>(
      create: (context) => CommunityBloc(lemmyClient: LemmyClient.instance),
      child: BlocListener<CommunityBloc, CommunityState>(
        listener: (context, state) {
          if (state.status == CommunityStatus.success && state.communityView != null) {
            context.read<FeedBloc>().add(FeedCommunityViewUpdatedEvent(communityView: state.communityView!));
          }
        },
        child: Container(
          alignment: Alignment.centerRight,
          child: Dismissible(
            key: Key(communityView.community.id.toString()),
            onUpdate: (DismissUpdateDetails details) => details.reached ? widget.onDismiss() : null,
            direction: DismissDirection.startToEnd,
            child: FractionallySizedBox(
              widthFactor: 0.8,
              alignment: FractionalOffset.centerRight,
              child: Container(
                color: theme.colorScheme.background,
                alignment: Alignment.topRight,
                child: Column(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 100),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return SizeTransition(
                          sizeFactor: animation,
                          child: FadeTransition(opacity: animation, child: child),
                        );
                      },
                      child: communityView.blocked == false
                          ? Padding(
                              padding: const EdgeInsets.only(top: 10, left: 12, right: 12, bottom: 4),
                              child: CommunityActions(isUserLoggedIn: isUserLoggedIn, getCommunityResponse: widget.getCommunityResponse!),
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
                      child: communityView.subscribed != SubscribedType.subscribed && communityView.subscribed != SubscribedType.pending
                          ? BlockCommunityButton(communityView: communityView, isUserLoggedIn: isUserLoggedIn)
                          : null,
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
                          CommonMarkdownBody(body: communityView.community.description ?? ''),
                          const SidebarSectionHeader(value: "Stats"),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: CommunityStatsList(communityView: communityView),
                          ),
                          const SidebarSectionHeader(value: "Moderators"),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: CommunityModeratorList(getCommunityResponse: widget.getCommunityResponse!),
                          ),
                          Container(
                            child: widget.getCommunityResponse!.site != null
                                ? Column(
                                    children: [
                                      const SidebarSectionHeader(value: "Host Instance"),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: InstanceView(
                                          site: widget.getCommunityResponse!.site!,
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
  const CommunityStatsList({super.key, required this.communityView});

  final CommunityView communityView;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // TODO Make this use device date format
        SidebarStat(
          icon: Icons.cake_rounded,
          value: 'Created ${DateFormat.yMMMMd().format(communityView.community.published)} · ${formatTimeToString(dateTime: communityView.community.published.toIso8601String())} ago',
        ),
        const SizedBox(height: 8.0),
        SidebarStat(
          icon: Icons.people_rounded,
          value: '${NumberFormat("#,###,###,###").format(communityView.counts.subscribers)} Subscribers',
        ),
        SidebarStat(
          icon: Icons.wysiwyg_rounded,
          value: '${NumberFormat("#,###,###,###").format(communityView.counts.posts)} Posts',
        ),
        SidebarStat(
          icon: Icons.chat_rounded,
          value: '${NumberFormat("#,###,###,###").format(communityView.counts.comments)} Comments',
        ),
        const SizedBox(height: 8.0),
        SidebarStat(
          icon: Icons.calendar_month_rounded,
          value: '${NumberFormat("#,###,###,###").format(communityView.counts.usersActiveHalfYear)} users/6 mo',
        ),
        SidebarStat(
          icon: Icons.calendar_view_month_rounded,
          value: '${NumberFormat("#,###,###,###").format(communityView.counts.usersActiveMonth)} users/mo',
        ),
        SidebarStat(
          icon: Icons.calendar_view_week_rounded,
          value: '${NumberFormat("#,###,###,###").format(communityView.counts.usersActiveWeek)} users/wk',
        ),
        SidebarStat(
          icon: Icons.calendar_view_day_rounded,
          value: '${NumberFormat("#,###,###,###").format(communityView.counts.usersActiveDay)} users/day',
        ),
      ],
    );
  }
}

class CommunityModeratorList extends StatelessWidget {
  const CommunityModeratorList({super.key, required this.getCommunityResponse});

  final GetCommunityResponse getCommunityResponse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        for (CommunityModeratorView mods in getCommunityResponse.moderators)
          GestureDetector(
            onTap: () {
              navigateToFeedPage(context, feedType: FeedType.user, userId: mods.moderator.id);
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  UserAvatar(
                    person: mods.moderator,
                    radius: 20.0,
                  ),
                  const SizedBox(width: 16.0),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mods.moderator!.displayName ?? mods.moderator!.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${mods.moderator!.name} · ${fetchInstanceNameFromUrl(mods.moderator!.actorId)}',
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
      ],
    );
  }
}

class BlockCommunityButton extends StatelessWidget {
  const BlockCommunityButton({
    super.key,
    required this.communityView,
    required this.isUserLoggedIn,
  });

  final CommunityView communityView;
  final bool isUserLoggedIn;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunityBloc, CommunityState>(
      builder: (context, state) {
        bool blocked = false;

        if (state.communityView != null) {
          blocked = state.communityView!.blocked;
        } else {
          blocked = communityView.blocked;
        }

        return Padding(
          padding: EdgeInsets.only(top: blocked ? 10 : 4, left: 12, right: 12, bottom: 4),
          child: ElevatedButton(
            onPressed: isUserLoggedIn
                ? () {
                    HapticFeedback.heavyImpact();
                    hideSnackbar(context);
                    context.read<CommunityBloc>().add(CommunityActionEvent(communityAction: CommunityAction.block, communityId: communityView.community.id, value: !blocked));
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
                Text(blocked ? 'Unblock Community' : 'Block Community'),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CommunityActions extends StatelessWidget {
  const CommunityActions({super.key, required this.isUserLoggedIn, required this.getCommunityResponse});

  final bool isUserLoggedIn;
  final GetCommunityResponse getCommunityResponse;

  @override
  Widget build(BuildContext context) {
    CommunityView communityView = getCommunityResponse.communityView;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: isUserLoggedIn
                ? () async {
                    HapticFeedback.mediumImpact();
                    CommunityBloc communityBloc = context.read<CommunityBloc>();
                    AccountBloc accountBloc = context.read<AccountBloc>();
                    ThunderBloc thunderBloc = context.read<ThunderBloc>();
                    FeedBloc feedBloc = context.read<FeedBloc>();

                    final ThunderState state = context.read<ThunderBloc>().state;
                    final bool reduceAnimations = state.reduceAnimations;

                    SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
                    DraftPost? newDraftPost;
                    DraftPost? previousDraftPost;
                    String draftId = '${LocalSettings.draftsCache.name}-${communityView.community.id}';
                    String? draftPostJson = prefs.getString(draftId);
                    if (draftPostJson != null) {
                      previousDraftPost = DraftPost.fromJson(jsonDecode(draftPostJson));
                    }
                    Timer timer = Timer.periodic(const Duration(seconds: 10), (Timer t) {
                      if (newDraftPost?.isNotEmpty == true) {
                        prefs.setString(draftId, jsonEncode(newDraftPost!.toJson()));
                      }
                    });

                    Navigator.of(context)
                        .push(
                      SwipeablePageRoute(
                        transitionDuration: reduceAnimations ? const Duration(milliseconds: 100) : null,
                        canOnlySwipeFromEdge: true,
                        backGestureDetectionWidth: 45,
                        builder: (context) {
                          return MultiBlocProvider(
                            providers: [
                              BlocProvider<CommunityBloc>.value(value: communityBloc),
                              BlocProvider<AccountBloc>.value(value: accountBloc),
                              BlocProvider<ThunderBloc>.value(value: thunderBloc),
                              BlocProvider<FeedBloc>.value(value: feedBloc),
                            ],
                            child: CreatePostPage(
                              communityId: communityView.community.id,
                              communityView: getCommunityResponse.communityView,
                              previousDraftPost: previousDraftPost,
                              onUpdateDraft: (p) => newDraftPost = p,
                            ),
                          );
                        },
                      ),
                    )
                        .whenComplete(() async {
                      timer.cancel();

                      if (newDraftPost?.saveAsDraft == true && newDraftPost?.isNotEmpty == true) {
                        await Future.delayed(const Duration(milliseconds: 300));
                        showSnackbar(context, AppLocalizations.of(context)!.postSavedAsDraft);
                        prefs.setString(draftId, jsonEncode(newDraftPost!.toJson()));
                      } else {
                        prefs.remove(draftId);
                      }
                    });
                  }
                : null,
            style: TextButton.styleFrom(
              fixedSize: const Size.fromHeight(40),
              foregroundColor: null,
              padding: EdgeInsets.zero,
            ),
            child: Semantics(
              focused: true,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books_rounded),
                  SizedBox(width: 4.0),
                  Text('New Post', style: TextStyle(color: null)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10, height: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: isUserLoggedIn
                ? () {
                    HapticFeedback.mediumImpact();
                    context.read<CommunityBloc>().add(CommunityActionEvent(
                        communityAction: CommunityAction.follow, communityId: communityView.community.id, value: communityView.subscribed == SubscribedType.notSubscribed ? true : false));
                  }
                : null,
            style: TextButton.styleFrom(
              fixedSize: const Size.fromHeight(40),
              foregroundColor: null,
              padding: EdgeInsets.zero,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  switch (communityView.subscribed) {
                    SubscribedType.notSubscribed => Icons.add_circle_outline_rounded,
                    SubscribedType.pending => Icons.pending_outlined,
                    SubscribedType.subscribed => Icons.remove_circle_outline_rounded,
                  },
                ),
                const SizedBox(width: 4.0),
                Text(
                  switch (communityView.subscribed) {
                    SubscribedType.notSubscribed => 'Subscribe',
                    SubscribedType.pending => 'Pending...',
                    SubscribedType.subscribed => 'Unsubscribe',
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
