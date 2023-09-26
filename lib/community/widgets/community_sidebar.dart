import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/community/pages/create_post_page.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/core/singletons/preferences.dart';
import 'package:thunder/shared/common_markdown_body.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/shared/user_avatar.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/date_time.dart';
import 'package:thunder/utils/instance.dart';
import 'package:thunder/utils/navigate_user.dart';

class CommunitySidebar extends StatefulWidget {
  final FullCommunityView fullCommunityView;
  final Function onDismissed;

  const CommunitySidebar({super.key, required this.fullCommunityView, required this.onDismissed});

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

    return Dismissible(
      key: Key(widget.fullCommunityView.communityView.community.id.toString()),
      onUpdate: (DismissUpdateDetails details) => details.reached ? widget.onDismissed() : null,
      direction: DismissDirection.startToEnd,
      child: FractionallySizedBox(
        widthFactor: 1,
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
              child: widget.fullCommunityView.communityView.blocked == false
                  ? Padding(
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
                              onPressed: isUserLoggedIn
                                  ? () async {
                                      HapticFeedback.mediumImpact();
                                      CommunityBloc communityBloc = context.read<CommunityBloc>();
                                      AccountBloc accountBloc = context.read<AccountBloc>();
                                      ThunderBloc thunderBloc = context.read<ThunderBloc>();

                                      final ThunderState state = context.read<ThunderBloc>().state;
                                      final bool reduceAnimations = state.reduceAnimations;

                                      SharedPreferences prefs = (await UserPreferences.instance).sharedPreferences;
                                      DraftPost? newDraftPost;
                                      DraftPost? previousDraftPost;
                                      String draftId = '${LocalSettings.draftsCache.name}-${widget.fullCommunityView.communityView.community.id}';
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
                                                BlocProvider<ThunderBloc>.value(value: thunderBloc)
                                              ],
                                              child: CreatePostPage(
                                                communityId: widget.fullCommunityView.communityView.community.id,
                                                communityInfo: widget.fullCommunityView,
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
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.library_books_rounded,
                                    semanticLabel: 'New Post',
                                  ),
                                  SizedBox(width: 4.0),
                                  Text(
                                    'New Post',
                                    style: TextStyle(
                                      color: null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                            height: 8,
                          ),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isUserLoggedIn
                                  ? () {
                                      HapticFeedback.mediumImpact();
                                      context.read<CommunityBloc>().add(
                                            ChangeCommunitySubsciptionStatusEvent(
                                              communityId: widget.fullCommunityView.communityView.community.id,
                                              follow: widget.fullCommunityView.communityView.subscribed == SubscribedType.notSubscribed ? true : false,
                                            ),
                                          );
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
                                    switch (widget.fullCommunityView.communityView.subscribed) {
                                      SubscribedType.notSubscribed => Icons.add_circle_outline_rounded,
                                      SubscribedType.pending => Icons.pending_outlined,
                                      SubscribedType.subscribed => Icons.remove_circle_outline_rounded,
                                      _ => Icons.add_circle_outline_rounded,
                                    },
                                    semanticLabel: (widget.fullCommunityView.communityView.subscribed == SubscribedType.notSubscribed) ? 'Subscribe' : 'Unsubscribe',
                                  ),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    switch (widget.fullCommunityView.communityView.subscribed) {
                                      SubscribedType.notSubscribed => 'Subscribe',
                                      SubscribedType.pending => 'Pending...',
                                      SubscribedType.subscribed => 'Unsubscribe',
                                      _ => '',
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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
              child: widget.fullCommunityView.communityView.subscribed != SubscribedType.subscribed && widget.fullCommunityView.communityView.subscribed != SubscribedType.pending
                  ? Padding(
                      padding: EdgeInsets.only(
                        top: widget.fullCommunityView.communityView.blocked ? 10 : 4,
                        left: 12,
                        right: 12,
                        bottom: 4,
                      ),
                      child: ElevatedButton(
                        onPressed: isUserLoggedIn
                            ? () {
                                HapticFeedback.heavyImpact();
                                hideSnackbar(context);
                                context.read<CommunityBloc>().add(
                                      BlockCommunityEvent(
                                        communityId: widget.fullCommunityView.communityView.community.id,
                                        block: widget.fullCommunityView.communityView.blocked == true ? false : true,
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
                              widget.fullCommunityView.communityView.blocked == true ? Icons.undo_rounded : Icons.block_rounded,
                              semanticLabel: widget.fullCommunityView.communityView.blocked == true ? 'Unblock Community' : 'Block Community',
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              widget.fullCommunityView.communityView.blocked == true ? 'Unblock Community' : 'Block Community',
                            ),
                          ],
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 10.0),
            const Divider(height: 0, thickness: 2),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              height: MediaQuery.of(context).size.height - 70 - 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        CommonMarkdownBody(
                          body: widget.fullCommunityView.communityView.community.description ?? '',
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 12.0, bottom: 6),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // TODO Make this use device date format
                              SidebarStat(
                                icon: Icons.cake_rounded,
                                value:
                                    'Created ${DateFormat.yMMMMd().format(widget.fullCommunityView.communityView.community.published)} · ${formatTimeToString(dateTime: widget.fullCommunityView!.communityView.community.published.toIso8601String())} ago',
                              ),
                              const SizedBox(height: 8.0),
                              SidebarStat(
                                icon: Icons.people_rounded,
                                value: '${NumberFormat("#,###,###,###").format(widget.fullCommunityView.communityView.counts.subscribers)} Subscribers',
                              ),
                              SidebarStat(
                                icon: Icons.wysiwyg_rounded,
                                value: '${NumberFormat("#,###,###,###").format(widget.fullCommunityView.communityView.counts.posts)} Posts',
                              ),
                              SidebarStat(
                                icon: Icons.chat_rounded,
                                value: '${NumberFormat("#,###,###,###").format(widget.fullCommunityView.communityView.counts.comments)} Comments',
                              ),
                              const SizedBox(height: 8.0),
                              SidebarStat(
                                icon: Icons.calendar_month_rounded,
                                value: '${NumberFormat("#,###,###,###").format(widget.fullCommunityView.communityView.counts.usersActiveHalfYear)} users/6 mo',
                              ),
                              SidebarStat(
                                icon: Icons.calendar_view_month_rounded,
                                value: '${NumberFormat("#,###,###,###").format(widget.fullCommunityView.communityView.counts.usersActiveMonth)} users/mo',
                              ),
                              SidebarStat(
                                icon: Icons.calendar_view_week_rounded,
                                value: '${NumberFormat("#,###,###,###").format(widget.fullCommunityView.communityView.counts.usersActiveWeek)} users/wk',
                              ),
                              SidebarStat(
                                icon: Icons.calendar_view_day_rounded,
                                value: '${NumberFormat("#,###,###,###").format(widget.fullCommunityView.communityView.counts.usersActiveDay)} users/day',
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 16.0, bottom: 8),
                          child: Row(children: [
                            Text("Moderators"),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            children: [
                              for (var mods in widget.fullCommunityView.moderators)
                                GestureDetector(
                                  onTap: () {
                                    navigateToUserPage(context, userId: mods.moderator!.id);
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
                          ),
                        ),
                        Container(
                          child: widget.fullCommunityView.site != null
                              ? Column(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 12.0, bottom: 4),
                                      child: Row(children: [
                                        Text("Host Instance"),
                                        Expanded(
                                          child: Divider(
                                            height: 5,
                                            thickness: 2,
                                            indent: 15,
                                          ),
                                        ),
                                      ]),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: widget.fullCommunityView.site?.icon != null ? Colors.transparent : theme.colorScheme.secondaryContainer,
                                                foregroundImage: widget.fullCommunityView?.site?.icon != null ? CachedNetworkImageProvider(widget.fullCommunityView!.site!.icon!) : null,
                                                maxRadius: 24,
                                                child: widget.fullCommunityView?.site?.icon == null
                                                    ? Text(
                                                        widget.fullCommunityView?.moderators.first.moderator!.name[0].toUpperCase() ?? '',
                                                        semanticsLabel: '',
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                              const SizedBox(width: 16.0),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    widget.fullCommunityView?.site?.name ?? /*fullCommunityView?.instanceHost ??*/ '',
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                                                  ),
                                                  Text(
                                                    widget.fullCommunityView?.site?.description ?? '',
                                                    style: theme.textTheme.bodyMedium,
                                                    overflow: TextOverflow.visible,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const Divider(),
                                          CommonMarkdownBody(
                                            body: widget.fullCommunityView?.site?.sidebar ?? '' /*?? fullCommunityView?.instanceHost*/,
                                          ),
                                        ],
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
          ],
        ),
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
