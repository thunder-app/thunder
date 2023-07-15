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
    required this.communityInfo
  });

  @override
  State<CommunitySidebar> createState() => _CommunitySidebarState();
}

class _CommunitySidebarState extends State<CommunitySidebar> {
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

    return Column(
      children: [
        CommunityHeader(communityInfo: widget.communityInfo),
        Container(
          color: theme.colorScheme.background,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text('stats'),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                    },
                    style: TextButton.styleFrom(
                      /*fixedSize: const Size.fromHeight(40),*/
                      foregroundColor: null,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Row(
                      children: [
                        Spacer(),
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
                        Spacer(),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                    },
                    style: TextButton.styleFrom(
                      /*fixedSize: const Size.fromHeight(40),*/
                      foregroundColor: null,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Row(
                      children: [
                        Spacer(),
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
                        Spacer(),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                MarkdownBody(data: widget.communityInfo?.communityView.community.description ?? '', ),
                const Divider(),
                const Text('Moderated by:'),
                Builder(

                  builder: (context) {
                    return const Text( widget.communityInfo?.moderators.first.moderator.displayName );
                  }
                ),
                const Divider(),
                MarkdownBody(data: widget.communityInfo?.site?.sidebar ?? '', ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
