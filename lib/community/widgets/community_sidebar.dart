import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:lemmy_api_client/v3.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/community/bloc/community_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/singletons/lemmy_client.dart';
import 'package:thunder/utils/instance.dart';

import '../../shared/common_markdown_body.dart';
import '../pages/create_post_page.dart';
import 'community_header.dart';

class CommunitySidebar extends StatefulWidget {

  final FullCommunityView? communityInfo;
  final SubscribedType? subscribedType;

  const CommunitySidebar({
    super.key,
    required this.communityInfo,
    required this.subscribedType,
  });

  @override
  State<CommunitySidebar> createState() => _CommunitySidebarState();
}

class _CommunitySidebarState extends State<CommunitySidebar>{
  final ScrollController _scrollController = ScrollController();

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
                if (widget.communityInfo?.communityView.blocked == false) Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 12, right: 12,),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isUserLoggedIn ? () {
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
                          } : null,
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
                      const SizedBox( width: 8, height: 8,),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isUserLoggedIn ? () {
                            HapticFeedback.mediumImpact();
                            context.read<CommunityBloc>().add(
                              ChangeCommunitySubsciptionStatusEvent(
                                communityId: widget.communityInfo!.communityView.community.id,
                                follow: (widget.subscribedType == null) ? true : (widget.subscribedType == SubscribedType.notSubscribed ? true : false),
                              ),
                            );
                          } : null,
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
                              Text( switch (widget.subscribedType) {
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
                ),
                if (widget.subscribedType != SubscribedType.subscribed) Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 12, right: 12,),
                  child: ElevatedButton(
                    onPressed: isUserLoggedIn ? () {
                      HapticFeedback.heavyImpact();
                      ScaffoldMessenger.of(context).clearSnackBars();
                      context.read<CommunityBloc>().add(
                        BlockCommunityEvent(
                          communityId: widget.communityInfo!.communityView.community.id,
                          block: widget.communityInfo?.communityView.blocked == true ? false : true,
                        ),
                      );
                    } : null,
                    style: TextButton.styleFrom(
                      fixedSize: const Size.fromHeight(40),
                      foregroundColor: Colors.redAccent,
                      padding: EdgeInsets.zero,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.communityInfo?.communityView.blocked == true ? Icons.undo_rounded : Icons.block_rounded,
                          semanticLabel: widget.communityInfo?.communityView.blocked == true ? 'Unblock Community' : 'Block Community',
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          widget.communityInfo?.communityView.blocked == true ? 'Unblock Community' : 'Block Community',
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8,),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8,),
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
                                  Wrap(
                                    spacing: 30,
                                    alignment: WrapAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        'Subscribers · ${widget.communityInfo?.communityView.counts.subscribers}',
                                        style: TextStyle( color: theme.textTheme.titleSmall?.color?.withOpacity(0.5) ),
                                      ),
                                      Text(
                                        'Posts · ${widget.communityInfo?.communityView.counts.posts}',
                                        style: TextStyle( color: theme.textTheme.titleSmall?.color?.withOpacity(0.5) ),
                                      ),
                                      Text(
                                        'Comments · ${widget.communityInfo?.communityView.counts.comments}',
                                        style: TextStyle( color: theme.textTheme.titleSmall?.color?.withOpacity(0.5) ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8.0),
                                  Wrap(
                                    spacing: 30,
                                    alignment: WrapAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        'Bi-Annual · ${widget.communityInfo?.communityView.counts.usersActiveHalfYear}',
                                        style: TextStyle( color: theme.textTheme.titleSmall?.color?.withOpacity(0.4) ),
                                      ),
                                      Text(
                                        'Monthly · ${widget.communityInfo?.communityView.counts.usersActiveMonth}',
                                        style: TextStyle( color: theme.textTheme.titleSmall?.color?.withOpacity(0.4) ),
                                      ),
                                      Text(
                                        'Weekly · ${widget.communityInfo?.communityView.counts.usersActiveWeek}',
                                        style: TextStyle( color: theme.textTheme.titleSmall?.color?.withOpacity(0.4) ),
                                      ),
                                      Text(
                                        'Daily · ${widget.communityInfo?.communityView.counts.usersActiveDay}',
                                        style: TextStyle( color: theme.textTheme.titleSmall?.color?.withOpacity(0.4) ),
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
                                children: [ for (var mods in widget.communityInfo!.moderators)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: mods.moderator?.avatar != null ? Colors.transparent : theme.colorScheme.secondaryContainer,
                                          foregroundImage: mods.moderator?.avatar != null ? CachedNetworkImageProvider( mods.moderator!.avatar! ) : null,
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
                                ],
                              ),
                            ),
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
                                        foregroundImage: widget.communityInfo?.site?.icon != null ? CachedNetworkImageProvider( widget.communityInfo!.site!.icon! ) : null,
                                        maxRadius: 24,
                                        child: widget.communityInfo?.site?.icon == null ? Text(
                                          widget.communityInfo?.moderators.first.moderator!.name[0].toUpperCase() ?? '',
                                          semanticsLabel: '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ) : null,
                                      ),
                                      const SizedBox(width: 16.0),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              widget.communityInfo?.site?.name ?? widget.communityInfo?.instanceHost ?? '',
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
                                    body: widget.communityInfo?.site?.sidebar ?? widget.communityInfo?.instanceHost ?? '',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 128,)
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
