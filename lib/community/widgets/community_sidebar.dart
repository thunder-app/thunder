import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/account/bloc/account_bloc.dart' as account_bloc;
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/utils/instance.dart';

import '../../shared/common_markdown_body.dart';
import '../../thunder/bloc/thunder_bloc.dart';
import '../../user/pages/user_page.dart';
import '../../utils/date_time.dart';
import '../pages/create_post_page.dart';
import 'community_header.dart';

class CommunitySidebar extends StatefulWidget {
  final FullCommunityView? communityInfo;
  final SubscribedType? subscribedType;
  final BlockedCommunity? blockedCommunity;

  const CommunitySidebar({
    super.key,
    required this.communityInfo,
    required this.subscribedType,
    required this.blockedCommunity,
  });

  @override
  State<CommunitySidebar> createState() => _CommunitySidebarState();
}

class _CommunitySidebarState extends State<CommunitySidebar> with TickerProviderStateMixin {
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
    final bool isUserLoggedIn = context.read<AuthBloc>().state.isLoggedIn;

    if (widget.blockedCommunity != null) {
      isBlocked = widget.blockedCommunity!.blocked;
    } else {
      isBlocked = widget.communityInfo!.communityView.blocked;
    }

    return Container(
      alignment: Alignment.topRight,
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Container(
            color: theme.colorScheme.background,
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
                  child: isBlocked == false
                      ? Padding(
                          padding: const EdgeInsets.only(
                            top: 8.0,
                            left: 12,
                            right: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: isUserLoggedIn
                                      ? () {
                                          HapticFeedback.mediumImpact();
                                          CommunityBloc communityBloc = context.read<CommunityBloc>();
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return BlocProvider<CommunityBloc>.value(
                                                  value: communityBloc,
                                                  child: CreatePostPage(communityId: widget.communityInfo!.communityView.community.id, communityInfo: widget.communityInfo),
                                                );
                                              },
                                            ),
                                          );
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
                                width: 8,
                                height: 8,
                              ),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: isUserLoggedIn
                                      ? () {
                                          HapticFeedback.mediumImpact();
                                          context.read<CommunityBloc>().add(
                                                ChangeCommunitySubsciptionStatusEvent(
                                                  communityId: widget.communityInfo!.communityView.community.id,
                                                  follow: (widget.subscribedType == null) ? true : (widget.subscribedType == SubscribedType.notSubscribed ? true : false),
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
                                        switch (widget.subscribedType) {
                                          SubscribedType.notSubscribed => Icons.add_circle_outline_rounded,
                                          SubscribedType.pending => Icons.pending_outlined,
                                          SubscribedType.subscribed => Icons.remove_circle_outline_rounded,
                                          _ => Icons.add_circle_outline_rounded,
                                        },
                                        semanticLabel: (widget.subscribedType == SubscribedType.notSubscribed || widget.subscribedType == null) ? 'Subscribe' : 'Unsubscribe',
                                      ),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        switch (widget.subscribedType) {
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
                  child: widget.subscribedType != SubscribedType.subscribed
                      ? Padding(
                          padding: const EdgeInsets.only(
                            top: 8.0,
                            left: 12,
                            right: 12,
                          ),
                          child: ElevatedButton(
                            onPressed: isUserLoggedIn
                                ? () {
                                    HapticFeedback.heavyImpact();
                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    context.read<CommunityBloc>().add(
                                          BlockCommunityEvent(
                                            communityId: widget.communityInfo!.communityView.community.id,
                                            block: isBlocked == true ? false : true,
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
                                  isBlocked == true ? Icons.undo_rounded : Icons.block_rounded,
                                  semanticLabel: isBlocked == true ? 'Unblock Community' : 'Block Community',
                                ),
                                const SizedBox(width: 4.0),
                                Text(
                                  isBlocked == true ? 'Unblock Community' : 'Block Community',
                                ),
                              ],
                            ),
                          ),
                        )
                      : null,
                ),
                const Divider(),
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
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                right: 8,
                                bottom: 8,
                              ),
                              child: CommonMarkdownBody(
                                body: widget.communityInfo?.communityView.community.description ?? '',
                              ),
                            ),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // TODO Make this use device date format
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8, top: 2, bottom: 2),
                                        child: Icon(
                                          Icons.cake_rounded,
                                          size: 18,
                                          color: theme.colorScheme.onBackground.withOpacity(0.65),
                                        ),
                                      ),
                                      Text(
                                        'Created ${DateFormat.yMMMMd().format(widget.communityInfo!.communityView.community.published)} · ${formatTimeToString(dateTime: widget.communityInfo!.communityView.community.published.toIso8601String())} ago',
                                        style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.65)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8, top: 2, bottom: 2),
                                        child: Icon(
                                          Icons.people_rounded,
                                          size: 18,
                                          color: theme.colorScheme.onBackground.withOpacity(0.65),
                                        ),
                                      ),
                                      Text(
                                        '${NumberFormat("#,###,###,###").format(widget.communityInfo?.communityView.counts.subscribers)} Subscribers',
                                        style: TextStyle(color: theme.textTheme.titleSmall?.color?.withOpacity(0.65)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8, top: 2, bottom: 2),
                                        child: Icon(
                                          Icons.wysiwyg_rounded,
                                          size: 18,
                                          color: theme.colorScheme.onBackground.withOpacity(0.65),
                                        ),
                                      ),
                                      Text(
                                        '${NumberFormat("#,###,###,###").format(widget.communityInfo?.communityView.counts.posts)} Posts',
                                        style: TextStyle(color: theme.textTheme.titleSmall?.color?.withOpacity(0.65)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8, top: 2, bottom: 2),
                                        child: Icon(
                                          Icons.chat_rounded,
                                          size: 18,
                                          color: theme.colorScheme.onBackground.withOpacity(0.65),
                                        ),
                                      ),
                                      Text(
                                        '${NumberFormat("#,###,###,###").format(widget.communityInfo?.communityView.counts.comments)} Comments',
                                        style: TextStyle(color: theme.textTheme.titleSmall?.color?.withOpacity(0.65)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8, top: 2, bottom: 2),
                                        child: Icon(
                                          Icons.calendar_month_rounded,
                                          size: 18,
                                          color: theme.colorScheme.onBackground.withOpacity(0.65),
                                        ),
                                      ),
                                      Text(
                                        '${NumberFormat("#,###,###,###").format(widget.communityInfo?.communityView.counts.usersActiveHalfYear)} users in six months',
                                        style: TextStyle(color: theme.textTheme.titleSmall?.color?.withOpacity(0.65)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8, top: 2, bottom: 2),
                                        child: Icon(
                                          Icons.calendar_view_month_rounded,
                                          size: 18,
                                          color: theme.colorScheme.onBackground.withOpacity(0.65),
                                        ),
                                      ),
                                      Text(
                                        '${NumberFormat("#,###,###,###").format(widget.communityInfo?.communityView.counts.usersActiveMonth)} users a month',
                                        style: TextStyle(color: theme.textTheme.titleSmall?.color?.withOpacity(0.65)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8, top: 2, bottom: 2),
                                        child: Icon(
                                          Icons.calendar_view_week_rounded,
                                          size: 18,
                                          color: theme.colorScheme.onBackground.withOpacity(0.65),
                                        ),
                                      ),
                                      Text(
                                        '${NumberFormat("#,###,###,###").format(widget.communityInfo?.communityView.counts.usersActiveWeek)} users a week',
                                        style: TextStyle(color: theme.textTheme.titleSmall?.color?.withOpacity(0.65)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8, top: 2, bottom: 2),
                                        child: Icon(
                                          Icons.calendar_view_day_rounded,
                                          size: 18,
                                          color: theme.colorScheme.onBackground.withOpacity(0.65),
                                        ),
                                      ),
                                      Text(
                                        '${NumberFormat("#,###,###,###").format(widget.communityInfo?.communityView.counts.usersActiveDay)} users a day',
                                        style: TextStyle(color: theme.textTheme.titleSmall?.color?.withOpacity(0.65)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40.0),
                            const Text('Moderators:'),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                children: [
                                  for (var mods in widget.communityInfo!.moderators)
                                    GestureDetector(
                                      onTap: () {
                                        account_bloc.AccountBloc accountBloc = context.read<account_bloc.AccountBloc>();
                                        AuthBloc authBloc = context.read<AuthBloc>();
                                        ThunderBloc thunderBloc = context.read<ThunderBloc>();

                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => MultiBlocProvider(
                                              providers: [
                                                BlocProvider.value(value: accountBloc),
                                                BlocProvider.value(value: authBloc),
                                                BlocProvider.value(value: thunderBloc),
                                              ],
                                              child: UserPage(userId: mods.moderator!.id),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: mods.moderator?.avatar != null ? Colors.transparent : theme.colorScheme.secondaryContainer,
                                              foregroundImage: mods.moderator?.avatar != null ? CachedNetworkImageProvider(mods.moderator!.avatar!) : null,
                                              maxRadius: 20,
                                              child: Text(
                                                mods.moderator!.name[0].toUpperCase() ?? '',
                                                semanticsLabel: '',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16.0),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    mods.moderator!.displayName ?? mods.moderator!.name ?? '',
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${mods.moderator!.name ?? ''} · ${fetchInstanceNameFromUrl(mods.moderator!.actorId)}',
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
                                ],
                              ),
                            ),
                            Container(
                              child: widget.communityInfo?.site != null
                                  ? Column(
                                      children: [
                                        const SizedBox(height: 40),
                                        const Text('Community host instance:'),
                                        const Divider(),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor: widget.communityInfo?.site?.icon != null ? Colors.transparent : theme.colorScheme.secondaryContainer,
                                                    foregroundImage: widget.communityInfo?.site?.icon != null ? CachedNetworkImageProvider(widget.communityInfo!.site!.icon!) : null,
                                                    maxRadius: 24,
                                                    child: widget.communityInfo?.site?.icon == null
                                                        ? Text(
                                                            widget.communityInfo?.moderators.first.moderator!.name[0].toUpperCase() ?? '',
                                                            semanticsLabel: '',
                                                            style: const TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 16,
                                                            ),
                                                          )
                                                        : null,
                                                  ),
                                                  const SizedBox(width: 16.0),
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          widget.communityInfo?.site?.name ?? /*widget.communityInfo?.instanceHost ??*/ '',
                                                          overflow: TextOverflow.ellipsis,
                                                          maxLines: 1,
                                                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                                                        ),
                                                        Text(
                                                          widget.communityInfo?.site?.description ?? '',
                                                          style: theme.textTheme.bodyMedium,
                                                          overflow: TextOverflow.visible,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Divider(),
                                              CommonMarkdownBody(
                                                body: widget.communityInfo?.site?.sidebar ?? '' /*?? widget.communityInfo?.instanceHost*/,
                                              ),
                                            ],
                                          ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
