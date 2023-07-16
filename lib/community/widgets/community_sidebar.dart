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

import 'community_header.dart';

class CommunitySidebar extends StatefulWidget {

  final FullCommunityView? communityInfo;

  const CommunitySidebar({
    super.key,
    required this.communityInfo,
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
    bool isLoggedIn = context.read<AuthBloc>().state.isLoggedIn;

    AccountStatus status = context.read<AccountBloc>().state.status;

    return Container(
      alignment: Alignment.topRight,
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Container(
            color: theme.colorScheme.background,
            padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 8.0, top: 8.0,),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                        },
                        style: TextButton.styleFrom(
                          fixedSize: const Size.fromHeight(40),
                          foregroundColor: null,
                          padding: EdgeInsets.zero,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline_rounded,
                              semanticLabel: 'Subscribe',
                            ),
                            SizedBox(width: 4.0),
                            Text(
                              'Subscribe',
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
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                        },
                        style: TextButton.styleFrom(
                          fixedSize: const Size.fromHeight(40),
                          foregroundColor: Colors.redAccent,
                          padding: EdgeInsets.zero,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.block,
                              semanticLabel: 'Block community',
                            ),
                            SizedBox(width: 4.0),
                            Text(
                              'Block community',
                              style: TextStyle(
                                color: null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MarkdownBody(data: widget.communityInfo?.communityView.community.description ?? '', ),
                      ),
                      const Divider(),
                      Column(
                        children: [
                          Wrap(
                            spacing: 30,
                            alignment: WrapAlignment.spaceEvenly,
                            children: [
                              Text('Subscribers · ${widget.communityInfo?.communityView.counts.subscribers}'),
                              Text('Posts · ${widget.communityInfo?.communityView.counts.posts}'),
                              Text('Comments · ${widget.communityInfo?.communityView.counts.comments}'),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Wrap(
                            spacing: 30,
                            alignment: WrapAlignment.spaceEvenly,
                            children: [
                              Text('Bi-Annual · ${widget.communityInfo?.communityView.counts.usersActiveHalfYear}'),
                              Text('Monthly · ${widget.communityInfo?.communityView.counts.usersActiveMonth}'),
                              Text('Weekly · ${widget.communityInfo?.communityView.counts.usersActiveWeek}'),
                              Text('Daily · ${widget.communityInfo?.communityView.counts.usersActiveDay}'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 40.0),
                      const Text('Moderators:'),
                      const Divider(),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: widget.communityInfo?.moderators.first.moderator?.avatar != null ? Colors.transparent : theme.colorScheme.secondaryContainer,
                            foregroundImage: widget.communityInfo?.moderators.first.moderator?.avatar != null ? CachedNetworkImageProvider( widget.communityInfo!.moderators.first.moderator!.avatar! ) : null,
                            maxRadius: 16,
                            child: Text(
                              widget.communityInfo?.moderators.first.moderator!.name[0].toUpperCase() ?? '',
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
                                  widget.communityInfo?.moderators.first.moderator!.displayName ?? widget.communityInfo?.moderators.first.moderator!.name ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                Text(
                                  '${widget.communityInfo?.moderators.first.moderator!.name ?? ''} · ${fetchInstanceNameFromUrl(widget.communityInfo?.moderators.first.moderator!.actorId)}',
                                  style: theme.textTheme.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      const Text('Community host instance:'),
                      const Divider(),
                      Text(
                        '${widget.communityInfo?.site?.name}',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8, top: 16, bottom: 16),
                        child: MarkdownBody(data: widget.communityInfo?.site?.sidebar ?? '', ),
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
