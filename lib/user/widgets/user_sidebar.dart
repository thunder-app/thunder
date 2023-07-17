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

class UserSidebar extends StatefulWidget {

  final PersonViewSafe? userInfo;
  final List<CommunityModeratorView>? moderates;

  const UserSidebar({
    super.key,
    required this.userInfo,
    required this.moderates,
  });

  @override
  State<UserSidebar> createState() => _UserSidebarState();
}

class _UserSidebarState extends State<UserSidebar>{
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12, right: 12,),
                  child: Row(
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
                                semanticLabel: 'Message User',
                              ),
                              SizedBox(width: 4.0),
                              Text(
                                'Message User',
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
                                semanticLabel: 'Block User',
                              ),
                              SizedBox(width: 4.0),
                              Text(
                                'Block User',
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
                                body: widget.userInfo?.person.bio ?? '',
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 40.0),
                            Container(
                              child: widget.moderates != null ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Moderates:'),
                                  const Divider(),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Column(
                                      children: [ for (var mods in widget.moderates! )
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: mods.community.icon != null ? Colors.transparent : theme.colorScheme.secondaryContainer,
                                                foregroundImage: mods.community.icon  != null ? CachedNetworkImageProvider( mods.community.icon! ) : null,
                                                maxRadius: 20,
                                                child: Text(
                                                  mods.community.name[0].toUpperCase() ?? '',
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
                                                      mods.community.title ?? mods.community.name ?? '',
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${mods.community.name ?? ''} · ${fetchInstanceNameFromUrl(mods.community.actorId)}',
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
                                ],
                              ) : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 128,)
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, left: 12, right: 12,),
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
            ),
          ),
        ),
      ),
    );
  }
}